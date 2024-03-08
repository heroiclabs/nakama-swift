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

import Foundation
import Logging

/// HTTP Request adapter which uses NSURLSession to send requests.
/// - note: Accept header is always set as 'application/json'.
class HttpRequestAdapter: HttpAdapterProtocol {
    var logger: Logger?
    
    init(logger: Logger? = nil) {
        self.logger = logger
    }
    
    func sendAsync<T: Codable>(method: String, uri: URL, headers: [String: String] = [:], body: Data? = nil, timeoutSec: Int = 60) async throws -> T {
        var request = URLRequest(url: uri)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.timeoutInterval = TimeInterval(timeoutSec)
        
        if let body {
            request.httpBody = body
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            debugPrint(request)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    self.logger?.error("Request failed: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    self.logger?.error("Server returned an error")
                    guard let data else {
                        // No data
                        let apiError = ApiResponseError(grpcStatusCode: 0, message: "HTTPError")
                        apiError.statusCode = (response as? HTTPURLResponse)?.statusCode
                        continuation.resume(throwing: apiError)
                        return
                    }
                    
                    // Decode error data
                    do {
                        let apiError = try JSONDecoder().decode(ApiResponseError.self, from: data)
                        apiError.statusCode = (response as? HTTPURLResponse)?.statusCode
                        continuation.resume(throwing: apiError)
                    } catch {
                        self.logger?.error("Failed to decode error response: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    }
                    return
                }
                
                guard let mimeType = httpResponse.mimeType, mimeType == "application/json", let data = data else {
                    self.logger?.error("Invalid response data")
                    continuation.resume(throwing: NSError(domain: "InvalidResponse", code: 0, userInfo: nil))
                    return
                }
                
                do {
                    let string = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    debugPrint(string)
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    continuation.resume(returning: decodedResponse)
                } catch {
                    self.logger?.error("Failed to decode response: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
            task.resume()
        }
    }
}
