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

private let protoDateFormatters: [ISO8601DateFormatter] = {
    let fractional = ISO8601DateFormatter()
    fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let whole = ISO8601DateFormatter()
    whole.formatOptions = [.withInternetDateTime]
    return [fractional, whole]
}()

private func protoDateFromString(_ string: String) -> Date? {
    for formatter in protoDateFormatters {
        if let date = formatter.date(from: string) {
            return date
        }
    }
    return nil
}

private func protoStringFromDate(_ date: Date) -> String {
    protoDateFormatters[0].string(from: date)
}

extension KeyedDecodingContainer {
    func protoValue<T: Decodable>(_ key: Key, _ zero: T) throws -> T {
        try decodeIfPresent(T.self, forKey: key) ?? zero
    }

    func protoInt64(_ key: Key) throws -> Int? {
        if let string = try? decode(String.self, forKey: key) {
            return Int(string)
        }
        return try decodeIfPresent(Int.self, forKey: key)
    }

    func protoInt64Array(_ key: Key) throws -> [Int] {
        if let strings = try? decode([String].self, forKey: key) {
            return strings.compactMap { Int($0) }
        }
        return try decodeIfPresent([Int].self, forKey: key) ?? []
    }

    func protoDate(_ key: Key) throws -> Date? {
        guard let string = try decodeIfPresent(String.self, forKey: key) else {
            return nil
        }
        return protoDateFromString(string)
    }
}

extension KeyedEncodingContainer {
    /// Skips zero values, matching the server's EmitUnpopulated: false.
    mutating func protoEncode<T: Encodable & Equatable>(_ value: T, _ zero: T, forKey key: Key) throws {
        if value != zero {
            try encode(value, forKey: key)
        }
    }

    mutating func protoEncodeCollection<T: Encodable & Collection>(_ value: T, forKey key: Key) throws {
        if !value.isEmpty {
            try encode(value, forKey: key)
        }
    }

    mutating func protoEncodeInt64(_ value: Int, forKey key: Key) throws {
        if value != 0 {
            try encode(String(value), forKey: key)
        }
    }

    mutating func protoEncodeInt64IfPresent(_ value: Int?, forKey key: Key) throws {
        if let value {
            try encode(String(value), forKey: key)
        }
    }

    mutating func protoEncodeInt64Array(_ value: [Int], forKey key: Key) throws {
        if !value.isEmpty {
            try encode(value.map(String.init), forKey: key)
        }
    }

    mutating func protoEncodeDate(_ value: Date, forKey key: Key) throws {
        if value.timeIntervalSince1970 != 0 {
            try encode(protoStringFromDate(value), forKey: key)
        }
    }
}
