/*
 * Copyright © 2026 The Nakama Authors
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

import Foundation

actor SessionRefresher {
    /// Refresh this far ahead of the actual expiry.
    static let expiryWindow: TimeInterval = 5 * 60

    private var inFlight: [ObjectIdentifier: Task<Void, Error>] = [:]

    func refreshIfNeeded(
        _ session: Session,
        refresh: @escaping @Sendable (Session) async throws -> Session
    ) async throws {
        guard session.hasExpired(offset: Date().addingTimeInterval(Self.expiryWindow)) else { return }
        guard !session.isRefreshExpired else { throw NakamaError.sessionExpired }

        let key = ObjectIdentifier(session)
        if let existing = inFlight[key] {
            return try await existing.value
        }

        let task = Task { _ = try await refresh(session) }
        inFlight[key] = task
        defer { inFlight[key] = nil }
        try await task.value
    }
}
