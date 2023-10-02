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
@testable import Nakama

// A mock adapter for testing transient error handling.
final class TransientErrorMockAdapter: TransientErrorAdapter {
    /// A schedule of responses to simulate during testing.
    private let sendSchedule: [TransientErrorResponseType]
    
    private var sendAttempts: Int = 0
    
    init(sendSchedule: [TransientErrorResponseType]) {
        self.sendSchedule = sendSchedule
    }
    
    /// An overrided method to simulate different responses based on the schedule.
    override func sendAsync<T>(request: @escaping () async throws -> T) async throws -> T {
        if sendAttempts > sendSchedule.count - 1 {
            fatalError("Attempted to send more requests than scheduled responses.")
        }
        
        let responseType = sendSchedule[sendAttempts]
        sendAttempts += 1
        
        switch responseType {
        case .ServerOk:
            return try await request()
        case .TransientError:
            throw GRPCStatus(code: .unavailable, message: "Transient error")
        case .NonTransientError:
            throw GRPCStatus(code: .failedPrecondition, message: "Non-transient error")
        }
    }
}
