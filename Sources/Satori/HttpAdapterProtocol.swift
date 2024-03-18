/*
 * Copyright © 2024 The Satori Authors
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

import Logging
import Foundation

protocol HttpAdapterProtocol {
	/// The logger to use with the adapter.
    var logger: Logger? { get set }

	/// Send a HTTP request.
	///
	/// - Parameters:
	///   - method: HTTP method to use for this request.
	///   - uri: The fully qualified URI to use.
	///   - headers: Request headers to set.
	///   - body: Request content body to set.
	///   - timeoutSec: Request timeout.
	/// - Returns: A task which resolves to the contents of the response.
    func sendAsync<T: Codable>(method: String, uri: URL, headers: [String: String], body: Data?, timeoutSec: Int) async throws -> T
}
