/*
 * Copyright © 2021 The Nakama Authors
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

public final class Session {
    /// The authentication token used to construct this session.
    public private(set) var token: String

    /// Refresh token that can be used for session token renewal.
    public private(set) var refreshToken: String

    /// If the user account for this session was just created.
    public let created: Bool

    /// When this session was constructed locally.
    public let createTime: Date

    /// When this session expires.
    public private(set) var expiryTime: Date

    /// When the refresh token expires. Epoch when there is no refresh token.
    public private(set) var refreshExpiryTime: Date

    /// The username of the user who owns this session.
    public private(set) var username: String

    /// The ID of the user who owns this session.
    public private(set) var userId: String

    /// Any custom properties associated with this session.
    public private(set) var sessionVars: [String: String]

    public var isExpired: Bool { hasExpired(offset: Date()) }

    public var isRefreshExpired: Bool { hasRefreshExpired(offset: Date()) }

    public func hasExpired(offset: Date) -> Bool { offset > expiryTime }

    public func hasRefreshExpired(offset: Date) -> Bool { offset > refreshExpiryTime }

    init(token: String, refreshToken: String, created: Bool) throws {
        guard let claims = token.jwtClaims() else { throw NakamaError.invalidSessionToken }

        self.token = token
        self.refreshToken = refreshToken
        self.created = created
        self.createTime = Date()
        self.expiryTime = Date(timeIntervalSince1970: claims["exp"] as? Double ?? 0)
        self.refreshExpiryTime = Date(timeIntervalSince1970: 0)
        self.userId = claims["uid"] as? String ?? ""
        self.username = claims["usn"] as? String ?? ""
        self.sessionVars = claims["vrs"] as? [String: String] ?? [:]

        applyRefreshToken(refreshToken)
    }

    /// Rebuild a session from tokens held across app launches.
    public static func restore(token: String, refreshToken: String) throws -> Session {
        try Session(token: token, refreshToken: refreshToken, created: false)
    }

    /// Replace this session's tokens with renewed ones, and re-read the claims.
    func update(token: String, refreshToken: String) throws {
        guard let claims = token.jwtClaims() else { throw NakamaError.invalidSessionToken }

        self.token = token
        if let expiry = claims["exp"] as? Double { self.expiryTime = Date(timeIntervalSince1970: expiry) }
        if let userId = claims["uid"] as? String { self.userId = userId }
        if let username = claims["usn"] as? String { self.username = username }
        if let vars = claims["vrs"] as? [String: String] { self.sessionVars = vars }

        applyRefreshToken(refreshToken)
    }

    private func applyRefreshToken(_ refreshToken: String) {
        self.refreshToken = refreshToken
        guard let expiry = refreshToken.jwtClaims()?["exp"] as? Double else { return }
        self.refreshExpiryTime = Date(timeIntervalSince1970: expiry)
    }
}

private extension String {
    /// Decode the claims payload of a JWT. Nil if this is not a well-formed JWT.
    func jwtClaims() -> [String: Any]? {
        let segments = components(separatedBy: ".")
        guard segments.count == 3 else { return nil }

        // JWTs use unpadded base64url; Data(base64Encoded:) accepts neither.
        var encoded = segments[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        encoded += String(repeating: "=", count: (4 - encoded.count % 4) % 4)

        guard let data = Data(base64Encoded: encoded) else { return nil }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }
}

