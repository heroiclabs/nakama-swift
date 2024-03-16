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
import SwiftProtobuf

extension Date {
	/// Convert a swift Date to a protobuf timestamp.
    func toProtobufTimestamp() -> Google_Protobuf_Timestamp {
		return Google_Protobuf_Timestamp.with { $0.seconds = Int64(self.timeIntervalSince1970); $0.nanos = Int32(self.timeIntervalSince1970.truncatingRemainder(dividingBy: 1) * 1_000_000_000) }
	}

	/// Convert a swift Date to a RFC3339 formatted string.
	func toRFC3339FormatString() -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(identifier: "UTC")
		return formatter.string(from: self)
	}
}

extension Bool {
	/// Convert a swift Bool to a protobuf BoolValue.
	func toProtobufBool() -> Google_Protobuf_BoolValue {
		return Google_Protobuf_BoolValue.with { $0.value = self }
	}
}

extension Google_Protobuf_Timestamp {
	/// Convert a protobuf timestamp to a swift Date.
	func toDate() -> Date {
		return Date(timeIntervalSince1970: TimeInterval(self.seconds) + TimeInterval(self.nanos) / 1_000_000_000)
	}
}
