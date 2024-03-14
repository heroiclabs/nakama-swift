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

/// A protocol for the Satori client.
public protocol HttpClientProtocol {
	var scheme: String { get }
	var host: String { get }
	var port: Int { get }
	var globalRetryConfiguration: RetryConfiguration { get set }

	/// True if the session should be refreshed with an active refresh token.
	var autoRefreshSession: Bool { get }

	/// Authenticate against the server.
	///
	/// - Parameters:
	/// 	- id: An optional user id.
	/// 	- defaultProperties: Optional default properties to update with this call. If not set, properties are left as they are on the server.
	/// 	- customProperties: Optional custom properties to update with this call. If not set, properties are left as they are on the server.
	func authenticate(id: String, defaultProperties: [String: String]?, customProperties: [String: String]?, retryConfig: RetryConfiguration?) async throws -> SatoriSession

	/// Log out a session, invalidate a refresh token, or log out all sessions/refresh tokens for a user.
	///
	/// - Parameters:
	/// 	- session: The session of the user.
	func authenticateLogout(session: SatoriSession, retryConfig: RetryConfiguration?) async throws -> Void

	/// Refresh a user's session using a refresh token retrieved from a previous authentication request.
	///
	/// - Parameters:
	/// 	- session: The session of the user.
	func sessionRefresh(session: SatoriSession, retryConfig: RetryConfiguration?) async throws -> SatoriSession

	/// Send an event for this session.
	///
	/// - Parameters:
	/// 	- session: The session of the user.
	/// 	- Parameter event: The event to send.
	func event(session: SatoriSession, event: Event, retryConfig: RetryConfiguration?) async throws -> Void

	/// Send a batch of events for this session.
	///
	/// - Parameters:
	/// 	- session: The session of the user.
	/// 	- events: The batch of events which will be sent.
	func events(session: SatoriSession, events: [Event], retryConfig: RetryConfiguration?) async throws -> Void

	/// Get all experiments data.
	///
	/// - Parameters:
	/// 	- session: The session of the user.
	func getAllExperiments(session: SatoriSession, retryConfig: RetryConfiguration?) async throws -> ApiExperimentList

	/// Get specific experiments data.
	///
	/// - Parameters:
	/// 	- session: The session of the user.
	/// 	- names: Experiment names.
	func getExperiments(session: SatoriSession, names: [String], retryConfig: RetryConfiguration?) async throws -> ApiExperimentList

	/// Get a single flag for this identity.
	///
	/// - Parameters:
	/// 	- session: The session of the user.
	/// 	- name: The name of the flag.
	/// 	- defaultValue: The default value if the server is unreachable.
	func getFlag(session: SatoriSession, name: String, defaultValue: String?, retryConfig: RetryConfiguration?) async throws -> ApiFlag

	/// List all available flags for this identity.
	///
	/// - Parameters:
	/// 	- session: The session of the user.
	/// 	- names: Flag names, if empty string all flags are returned.
	func getFlags(session: SatoriSession, names: [String], retryConfig: RetryConfiguration?) async throws -> ApiFlagList

	/// List available live events.
	///
	/// - Parameters:
	/// 	- session: The session of the user.
	/// 	- names: Live event names, if null or empty, all live events are returned.
	func getLiveEvents(session: SatoriSession, names: [String]?, retryConfig: RetryConfiguration?) async throws -> ApiLiveEventList

	/// Identify a session with a new ID.
	///
	/// - Parameters:
	/// 	- session: The session of the user.
	/// 	- id: Identity ID to enrich the current session and return a new session. The old session will no longer be usable. Must be between eight and 128 characters (inclusive). Must be an alphanumeric string with only underscores and hyphens allowed.
	/// 	- defaultProperties: The default properties.
	/// 	- customProperties: The custom event properties.
	func identify(session: SatoriSession, id: String, defaultProperties: [String: String], customProperties: [String: String], retryConfig: RetryConfiguration?) async throws -> SatoriSession

	/// List properties associated with this identity.
	///
	/// - Parameters:
	/// 	- session: The session of the user.
	func listProperties(session: SatoriSession, retryConfig: RetryConfiguration?) async throws -> ApiProperties

	/// Update properties associated with this identity.
	///
	/// - Parameters:
	/// 	- session: The session of the user.
	/// 	- defaultProperties: The default properties to update.
	/// 	- customProperties: The custom properties to update.
	/// 	- recompute: Whether or not to recompute the user's audience membership immediately after property update.
	func updateProperties(session: SatoriSession, defaultProperties: [String: String], customProperties: [String: String], recompute: Bool?, retryConfig: RetryConfiguration?) async throws -> Void

	/// Delete the caller's identity and associated data.
	///
	/// - Parameters:
	/// 	- session: The session of the user.
	func deleteIdentity(session: SatoriSession, retryConfig: RetryConfiguration?) async throws -> Void
}
