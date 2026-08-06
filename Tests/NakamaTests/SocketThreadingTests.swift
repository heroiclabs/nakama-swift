/*
 * Copyright © 2026 Heroic Labs
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

import XCTest
import Atomics
@testable import Nakama

final class SocketThreadingTests: XCTestCase {
    // Reproduces the data race on Socket.collatedPromises/collatedFailers:
    // send() and its defer mutate the dictionaries on Swift-concurrency threads
    // while adapter callbacks (the URLSession delegate queue in production)
    // read and clear them concurrently. No synchronization guards either side.
    //
    // Run with: swift test --sanitize=thread --filter SocketThreadingTests
    func test_concurrentSendAndDisconnect_racesOnCollationDictionaries() async throws {
        let client = TestConfig.makeClient()
        let socket = client.createSocket() as! Socket

        let stop = ManagedAtomic<Bool>(false)
        let pump = OperationQueue()
        pump.addOperation {
            // Stands in for the URLSession delegate queue firing disconnects.
            // Loops until every pending rpc below has been failed, so no promise
            // outlives the event loop group.
            while !stop.load(ordering: .relaxed) {
                socket.socketAdapter.onDisconnect?()
            }
        }

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<1000 {
                group.addTask {
                    // Offline: send() registers the promise; the pump fails it.
                    _ = try? await socket.rpc(id: "ping", payload: nil)
                }
            }
        }

        stop.store(true, ordering: .relaxed)
        pump.waitUntilAllOperationsAreFinished()
        try await client.disconnect()
    }
}
