/*
 * Copyright © 2023 Heroic Labs
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import GRPC
import XCTest
@testable import Nakama

final class RetryTests: XCTestCase {
    
    func test_createSessionWithNonTransientError() async throws {
        let schedule = [TransientErrorResponseType.ServerOk]
        let mockAdapter = TransientErrorMockAdapter(sendSchedule: schedule)
        let client = GrpcClient(serverKey: "defaultkey", transientErrorAdapter: mockAdapter)
        let session = try await client.authenticateCustom(id: UUID().uuidString)
        XCTAssertNotNil(session)
    }
    
    func test_oneRetryRetriesOneTime() async throws {
        var lastRetryNum = 0
        let retryListener: RetryListener = { numRetry, _ in
            lastRetryNum = numRetry
        }
        
        let schedule: [TransientErrorResponseType] = [.TransientError, .ServerOk]
        let mockAdapter = TransientErrorMockAdapter(sendSchedule: schedule)
        let client = GrpcClient(serverKey: "defaultkey", transientErrorAdapter: mockAdapter)
        let config = client.globalRetryConfiguration
        config.maxRetries = 1
        config.baseDelay = 10
        config.retryListener = retryListener
        
        let session = try await client.authenticateCustom(id: UUID().uuidString, retryConfig: config)
        
        XCTAssertNotNil(session)
        XCTAssertEqual(lastRetryNum, 1)
    }
    
    func test_noRetriesThrowsGrpcException() async throws {
        let schedule = [TransientErrorResponseType.TransientError]
        let mockAdapter = TransientErrorMockAdapter(sendSchedule: schedule)
        
        let client = GrpcClient(serverKey: "defaultkey", transientErrorAdapter: mockAdapter)
        do {
            _ = try await client.authenticateCustom(id: UUID().uuidString, retryConfig: RetryConfiguration(baseDelayMs: 1, maxRetries: 0))
            XCTFail("Invalid request should fail")
        } catch {
            XCTAssertTrue(true)
        }
    }
    
    func test_zeroRetriesShouldNotRetry() async throws {
        var lastRetryNum = -1
        let retryListener: RetryListener = { numRetry, retry in
            lastRetryNum = numRetry
        }
        
        let schedule: [TransientErrorResponseType] = [.TransientError, .ServerOk]
        let mockAdapter = TransientErrorMockAdapter(sendSchedule: schedule)
        let client = GrpcClient(serverKey: "defaultKey", transientErrorAdapter: mockAdapter)
        let config = client.globalRetryConfiguration
        config.maxRetries = 0
        config.retryListener = retryListener
        
        do {
            _ = try await client.authenticateCustom(id: "-", retryConfig: config)
            XCTFail("Invalid request should fail")
        } catch {
            XCTAssertEqual(lastRetryNum, -1)
        }
    }
    
    func test_fiveRetriesRetryFiveTimes() async throws {
        let schedule: [TransientErrorResponseType] = [
            .TransientError,
            .TransientError,
            .TransientError,
            .TransientError,
            .TransientError,
            .ServerOk
        ]
        var lastRetryNum = -1
        let mockAdapter = TransientErrorMockAdapter(sendSchedule: schedule)
        let client = GrpcClient(serverKey: "defaultkey", transientErrorAdapter: mockAdapter)
        let config = client.globalRetryConfiguration
        config.maxRetries = 5
        config.baseDelay = 1
        config.retryListener = { numRetry, retry in
            lastRetryNum = numRetry
        }
        client.globalRetryConfiguration = config
        
        let session = try await client.authenticateCustom(id: UUID().uuidString)
        XCTAssertNotNil(session)
        XCTAssertEqual(lastRetryNum, 5)
    }
    
    func test_failingAfterMaxRetriesThrowsError() async throws {
        let schedule: [TransientErrorResponseType] = [
            .TransientError,
            .TransientError,
            .TransientError,
            .TransientError
        ]
        let mockAdapter = TransientErrorMockAdapter(sendSchedule: schedule)
        let client = GrpcClient(serverKey: "defaultkey", transientErrorAdapter: mockAdapter)
        
        var lastRetryNum = 0
        let retryListener: RetryListener = { retries, retry in
            lastRetryNum = retries
        }
        let config = RetryConfiguration(baseDelayMs: 500, maxRetries: 3, retryListener: retryListener)
        do {
            _ = try await client.authenticateCustom(id: UUID().uuidString, retryConfig: config)
            XCTFail("Should fail with a transient error")
        } catch {
            XCTAssertEqual(lastRetryNum, 3)
            XCTAssertTrue(error is RetryInvokerError)
        }
    }
    
    func test_nonTransientErrorThrowsWithoutRetry() async throws {
        let schedule = [TransientErrorResponseType.NonTransientError]
        let mockAdapter = TransientErrorMockAdapter(sendSchedule: schedule)
        let client = GrpcClient(serverKey: "defaultkey", transientErrorAdapter: mockAdapter)
        
        do {
            _ = try await client.authenticateCustom(id: UUID().uuidString)
        } catch {
            XCTAssertTrue(error is GRPCStatus)
        }
    }
    
    func test_expectedExponentialTimes() async throws {
        let schedule: [TransientErrorResponseType] = [
            .TransientError,
            .TransientError,
            .TransientError,
            .ServerOk
        ]
        let mockAdapter = TransientErrorMockAdapter(sendSchedule: schedule)
        
        let client = GrpcClient(serverKey: "defaultkey", transientErrorAdapter: mockAdapter)
        
        var retries = [Retry]()
        let retryListener: RetryListener = { _, retry in
            retries.append(retry)
        }
        let config = RetryConfiguration(baseDelayMs: 10, maxRetries: 3, retryListener: retryListener)
        client.globalRetryConfiguration = config
        
        let session = try await client.authenticateCustom(id: "test_id")
        XCTAssertNotNil(session)
        XCTAssertEqual(retries[0].exponentialBackoff, 10)
        XCTAssertEqual(retries[1].exponentialBackoff, 20)
        XCTAssertEqual(retries[2].exponentialBackoff, 40)
    }
    
    func test_expectedDelays() async throws {
        let schedule: [TransientErrorResponseType] = [
            .TransientError,
            .TransientError,
            .TransientError,
            .NonTransientError
        ]
        let mockAdapter = TransientErrorMockAdapter(sendSchedule: schedule)
        let client = GrpcClient(serverKey: "defaultkey", transientErrorAdapter: mockAdapter)
        
        var retries = [Retry]()
        let retryListener: RetryListener = { _, retry in
            retries.append(retry)
        }
        let config = RetryConfiguration(baseDelayMs: 10, maxRetries: 3, retryListener: retryListener)
        client.globalRetryConfiguration = config
        
        let timeBeforeRequest = Date()
        var timeAfterRequest = Date()
        
        do {
            _ = try await client.authenticateCustom(id: "test_id")
            XCTFail()
        } catch {
            timeAfterRequest = Date()
        }
        
        let expectedElapsedMs = retries.reduce(0) { $0 + $1.jitterBackoff }
        let actualElapsedMs = Int(timeAfterRequest.timeIntervalSince(timeBeforeRequest) * 1000)
        XCTAssertTrue(expectedElapsedMs < actualElapsedMs)
    }
    
    func test_customJitterDecorrelated() async throws {
        let schedule: [TransientErrorResponseType] = [
            .TransientError,
            .TransientError,
            .TransientError,
            .ServerOk
        ]
        let mockAdapter = TransientErrorMockAdapter(sendSchedule: schedule)
        let client = GrpcClient(serverKey: "defaultkey", transientErrorAdapter: mockAdapter)
        let jitter: Jitter = { history, delay, random in
            let delayCap = 20000
            return min(delayCap, Int(random.next(in: Double(delay)..<Double(history.last?.jitterBackoff ?? delay) * 3)))
        }
        client.globalRetryConfiguration = RetryConfiguration(baseDelayMs: 500, maxRetries: 3, jitter: jitter)
        
        let session = try await client.authenticateCustom(id: "test_id")
        XCTAssertNotNil(session)
    }
}
