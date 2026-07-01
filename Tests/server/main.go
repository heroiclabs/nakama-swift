package main

import (
	"context"
	"crypto/rand"
	"database/sql"
	"encoding/json"
	"fmt"
	"strings"
	"sync"
	"time"

	"github.com/heroiclabs/nakama-common/runtime"
)

// retryAttempts tracks per-test_id call counts for the retry_test RPC.
var retryAttempts sync.Map

//goland:noinspection GoUnusedExportedFunction
func InitModule(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, initializer runtime.Initializer) error {
	initStart := time.Now()

	if err := initializer.RegisterRpc("transform", rpcTransform); err != nil {
		return err
	}

	if err := initializer.RegisterRpc("always_fail", rpcAlwaysFail); err != nil {
		return err
	}

	if err := initializer.RegisterRpc("retry_test", rpcRetryTest); err != nil {
		return err
	}

	if err := initializer.RegisterRpc("clientrpc.send_notification", rpcSendNotification); err != nil {
		return err
	}

	if err := initializer.RegisterRpc("clientrpc.rpc_get", rpcGet); err != nil {
		return err
	}

	if err := initializer.RegisterRpc("clientrpc.rpc", rpcEcho); err != nil {
		return err
	}

	if err := initializer.RegisterRpc("clientrpc.create_leaderboard", rpcCreateLeaderboard); err != nil {
		return err
	}

	logger.Info("Test server plugin loaded in %dms", time.Since(initStart).Milliseconds())
	return nil
}

func rpcTransform(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	var input map[string]interface{}
	if err := json.Unmarshal([]byte(payload), &input); err != nil {
		return "", runtime.NewError("invalid JSON payload", 3) // INVALID_ARGUMENT
	}

	msg, ok := input["message"].(string)
	if !ok {
		return "", runtime.NewError("missing or invalid 'message' field", 3) // INVALID_ARGUMENT
	}

	// Reverse the string
	runes := []rune(msg)
	for i, j := 0, len(runes)-1; i < j; i, j = i+1, j-1 {
		runes[i], runes[j] = runes[j], runes[i]
	}

	result := map[string]interface{}{
		"original": msg,
		"reversed": string(runes),
		"length":   len([]rune(msg)),
		"upper":    strings.ToUpper(msg),
	}

	out, err := json.Marshal(result)
	if err != nil {
		return "", runtime.NewError("failed to marshal response", 13) // INTERNAL
	}
	return string(out), nil
}

func rpcAlwaysFail(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	return "", runtime.NewError("always fails", 14) // UNAVAILABLE
}

func rpcSendNotification(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	var input struct {
		UserID string `json:"user_id"`
	}
	if err := json.Unmarshal([]byte(payload), &input); err != nil {
		return "", runtime.NewError("invalid JSON payload", 3) // INVALID_ARGUMENT
	}
	if input.UserID == "" {
		return "", runtime.NewError("missing user_id", 3) // INVALID_ARGUMENT
	}

	if err := nk.NotificationSend(ctx, input.UserID, "test-notification", map[string]interface{}{"message": "hello"}, 1, input.UserID, true); err != nil {
		return "", runtime.NewError("failed to send notification", 13) // INTERNAL
	}

	return payload, nil
}

func rpcGet(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	return "{\"message\":\"PONG\"}", nil
}

func rpcEcho(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	return payload, nil
}

func rpcCreateLeaderboard(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	var input struct {
		Operator string `json:"operator"`
	}
	if err := json.Unmarshal([]byte(payload), &input); err != nil {
		return "", runtime.NewError("invalid JSON payload", 3) // INVALID_ARGUMENT
	}
	if input.Operator == "" {
		input.Operator = "best"
	}

	id, err := newUUID()
	if err != nil {
		return "", runtime.NewError("failed to generate leaderboard id", 13) // INTERNAL
	}

	if err := nk.LeaderboardCreate(ctx, id, false, "desc", input.Operator, "", nil, false); err != nil {
		return "", runtime.NewError("failed to create leaderboard", 13) // INTERNAL
	}

	out, err := json.Marshal(map[string]interface{}{"leaderboard_id": id})
	if err != nil {
		return "", runtime.NewError("failed to marshal response", 13) // INTERNAL
	}
	return string(out), nil
}

func newUUID() (string, error) {
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	b[6] = (b[6] & 0x0f) | 0x40 // version 4
	b[8] = (b[8] & 0x3f) | 0x80 // variant 10
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:16]), nil
}

func rpcRetryTest(ctx context.Context, logger runtime.Logger, db *sql.DB, nk runtime.NakamaModule, payload string) (string, error) {
	var input struct {
		TestID    string `json:"test_id"`
		FailCount int    `json:"fail_count"`
	}
	if err := json.Unmarshal([]byte(payload), &input); err != nil {
		return "", runtime.NewError("invalid JSON payload", 3) // INVALID_ARGUMENT
	}
	if input.TestID == "" {
		return "", runtime.NewError("missing test_id", 3) // INVALID_ARGUMENT
	}

	// Atomically increment the call count for this test_id.
	var count int
	if val, loaded := retryAttempts.LoadOrStore(input.TestID, new(int)); loaded {
		ptr := val.(*int)
		*ptr++
		count = *ptr
	} else {
		ptr := val.(*int)
		*ptr = 1
		count = 1
	}

	if count <= input.FailCount {
		return "", runtime.NewError(fmt.Sprintf("transient failure %d/%d", count, input.FailCount), 14) // UNAVAILABLE
	}

	result, _ := json.Marshal(map[string]interface{}{
		"attempts": count,
	})
	return string(result), nil
}
