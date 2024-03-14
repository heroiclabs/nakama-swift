/* Code generated by codegen/main.go. DO NOT EDIT. */

import Foundation

/// An Error generated for HTTPURLResponse that don't return a success status.
public final class ApiResponseError: Error, Decodable {
    /// The gRPC status code of the response.
	public let grpcStatusCode: Int
    
    /// The message of the response.
    public let message: String

    /// The http status code of the response.
	public var statusCode: Int?
	
    private enum CodingKeys: String, CodingKey {
        case grpcStatusCode = "code"
        case message
    }

    public init(grpcStatusCode: Int, message: String) {
        self.grpcStatusCode = grpcStatusCode
        self.message = message
    }

	public  var description: String {
		return "ApiResponseError(StatusCode=\(statusCode ?? 0), Message='\(message)', GrpcStatusCode=\(grpcStatusCode))"
	}
}

struct EmptyResponse: Codable {
    init() {}
}

/// The request to update the status of a message.
public protocol ApiUpdateMessageRequestProtocol: Codable {

    /// The time the message was consumed by the identity.
    var consumeTime: String { get }

    /// The time the message was read at the client.
    var readTime: String { get }
}

public class ApiUpdateMessageRequest: ApiUpdateMessageRequestProtocol
{
    public var consumeTime: String
    public var readTime: String

    private enum CodingKeys: String, CodingKey {
        case consumeTime = "consumeTime"
        case readTime = "readTime"
    }
    
    init(
        consumeTime: String,
        readTime: String
    ) {
        self.consumeTime = consumeTime
        self.readTime = readTime
    }

    var debugDescription: String {
        return "consumeTime: \(consumeTime)readTime: \(readTime)"
    }
}

/// Log out a session, invalidate a refresh token, or log out all sessions/refresh tokens for a user.
public protocol ApiAuthenticateLogoutRequestProtocol: Codable {

    /// Refresh token to invalidate.
    var refreshToken: String { get }

    /// Session token to log out.
    var token: String { get }
}

public class ApiAuthenticateLogoutRequest: ApiAuthenticateLogoutRequestProtocol
{
    public var refreshToken: String
    public var token: String

    private enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case token = "token"
    }
    
    init(
        refreshToken: String,
        token: String
    ) {
        self.refreshToken = refreshToken
        self.token = token
    }

    var debugDescription: String {
        return "refreshToken: \(refreshToken)token: \(token)"
    }
}

/// Authenticate against the server with a refresh token.
public protocol ApiAuthenticateRefreshRequestProtocol: Codable {

    /// Refresh token.
    var refreshToken: String { get }
}

public class ApiAuthenticateRefreshRequest: ApiAuthenticateRefreshRequestProtocol
{
    public var refreshToken: String

    private enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
    
    init(
        refreshToken: String
    ) {
        self.refreshToken = refreshToken
    }

    var debugDescription: String {
        return "refreshToken: \(refreshToken)"
    }
}

/// Authentication request
public protocol ApiAuthenticateRequestProtocol: Codable {

    /// Optional custom properties to update with this call. If not set, properties are left as they are on the server.
    var custom: [String: String]? { get }

    /// Optional default properties to update with this call. If not set, properties are left as they are on the server.
    var default_: [String: String]? { get }

    /// Identity ID. Must be between eight and 128 characters (inclusive). Must be an alphanumeric string with only underscores and hyphens allowed.
    var id: String { get }
}

public class ApiAuthenticateRequest: ApiAuthenticateRequestProtocol
{
    public var custom: [String: String]? = [:]
    public var default_: [String: String]? = [:]
    public var id: String

    private enum CodingKeys: String, CodingKey {
        case custom = "custom"
        case default_ = "default"
        case id = "id"
    }
    
    init(
        custom: [String: String] = [:],
        default_: [String: String] = [:],
        id: String
    ) {
        self.custom = custom
        self.default_ = default_
        self.id = id
    }

    var debugDescription: String {
        return "custom: \(custom)default: \(default_)id: \(id)"
    }
}

/// A single event. Usually, but not necessarily, part of a batch.
public protocol ApiEventProtocol: Codable {

    /// Optional event ID assigned by the client, used to de-duplicate in retransmission scenarios. If not supplied the server will assign a randomly generated unique event identifier.
    var id: String { get }

    /// Event metadata, if any.
    var metadata: [String: String]? { get }

    /// Event name.
    var name: String { get }

    /// The time when the event was triggered on the producer side.
    var timestamp: String { get }

    /// Optional value.
    var value: String { get }
}

public class ApiEvent: ApiEventProtocol
{
    public var id: String
    public var metadata: [String: String]? = [:]
    public var name: String
    public var timestamp: String
    public var value: String

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case metadata = "metadata"
        case name = "name"
        case timestamp = "timestamp"
        case value = "value"
    }
    
    init(
        id: String,
        metadata: [String: String] = [:],
        name: String,
        timestamp: String,
        value: String
    ) {
        self.id = id
        self.metadata = metadata
        self.name = name
        self.timestamp = timestamp
        self.value = value
    }

    var debugDescription: String {
        return "id: \(id)metadata: \(metadata)name: \(name)timestamp: \(timestamp)value: \(value)"
    }
}

/// Publish an event to the server
public protocol ApiEventRequestProtocol: Codable {

    /// Some number of events produced by a client.
    var events: [ApiEvent]? { get }
}

public class ApiEventRequest: ApiEventRequestProtocol
{
    public var events: [ApiEvent]? = []

    private enum CodingKeys: String, CodingKey {
        case events = "events"
    }
    
    init(
        events: [ApiEvent] = []
    ) {
        self.events = events
    }

    var debugDescription: String {
        return "events: \(events)"
    }
}

/// An experiment that this user is partaking.
public protocol ApiExperimentProtocol: Codable {

    /// Experiment name
    var name: String { get }

    /// Value associated with this Experiment.
    var value: String { get }
}

public class ApiExperiment: ApiExperimentProtocol
{
    public var name: String
    public var value: String

    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case value = "value"
    }
    
    init(
        name: String,
        value: String
    ) {
        self.name = name
        self.value = value
    }

    var debugDescription: String {
        return "name: \(name)value: \(value)"
    }
}

/// All experiments that this identity is involved with.
public protocol ApiExperimentListProtocol: Codable {

    /// All experiments for this identity.
    var experiments: [ApiExperiment]? { get }
}

public class ApiExperimentList: ApiExperimentListProtocol
{
    public var experiments: [ApiExperiment]? = []

    private enum CodingKeys: String, CodingKey {
        case experiments = "experiments"
    }
    
    init(
        experiments: [ApiExperiment] = []
    ) {
        self.experiments = experiments
    }

    var debugDescription: String {
        return "experiments: \(experiments)"
    }
}

/// Feature flag available to the identity.
public protocol ApiFlagProtocol: Codable {

    /// Whether the value for this flag has conditionally changed from the default state.
    var conditionChanged: Bool? { get }

    /// Flag name
    var name: String { get }

    /// Value associated with this flag.
    var value: String { get }
}

public class ApiFlag: ApiFlagProtocol
{
    public var conditionChanged: Bool?
    public var name: String
    public var value: String

    private enum CodingKeys: String, CodingKey {
        case conditionChanged = "conditionChanged"
        case name = "name"
        case value = "value"
    }
    
    init(
        conditionChanged: Bool,
        name: String,
        value: String
    ) {
        self.conditionChanged = conditionChanged
        self.name = name
        self.value = value
    }

    var debugDescription: String {
        return "conditionChanged: \(conditionChanged)name: \(name)value: \(value)"
    }
}

/// All flags available to the identity
public protocol ApiFlagListProtocol: Codable {

    /// All flags
    var flags: [ApiFlag]? { get }
}

public class ApiFlagList: ApiFlagListProtocol
{
    public var flags: [ApiFlag]? = []

    private enum CodingKeys: String, CodingKey {
        case flags = "flags"
    }
    
    init(
        flags: [ApiFlag] = []
    ) {
        self.flags = flags
    }

    var debugDescription: String {
        return "flags: \(flags)"
    }
}

/// A response containing all the messages for an identity.
public protocol ApiGetMessageListResponseProtocol: Codable {

    /// Cacheable cursor to list newer messages. Durable and designed to be stored, unlike next/prev cursors.
    var cacheableCursor: String { get }

    /// The list of messages.
    var messages: [ApiMessage]? { get }

    /// The cursor to send when retrieving the next page, if any.
    var nextCursor: String { get }

    /// The cursor to send when retrieving the previous page, if any.
    var prevCursor: String { get }
}

public class ApiGetMessageListResponse: ApiGetMessageListResponseProtocol
{
    public var cacheableCursor: String
    public var messages: [ApiMessage]? = []
    public var nextCursor: String
    public var prevCursor: String

    private enum CodingKeys: String, CodingKey {
        case cacheableCursor = "cacheableCursor"
        case messages = "messages"
        case nextCursor = "nextCursor"
        case prevCursor = "prevCursor"
    }
    
    init(
        cacheableCursor: String,
        messages: [ApiMessage] = [],
        nextCursor: String,
        prevCursor: String
    ) {
        self.cacheableCursor = cacheableCursor
        self.messages = messages
        self.nextCursor = nextCursor
        self.prevCursor = prevCursor
    }

    var debugDescription: String {
        return "cacheableCursor: \(cacheableCursor)messages: \(messages)nextCursor: \(nextCursor)prevCursor: \(prevCursor)"
    }
}

/// Enrich/replace the current session with a new ID.
public protocol ApiIdentifyRequestProtocol: Codable {

    /// Optional custom properties to update with this call. If not set, properties are left as they are on the server.
    var custom: [String: String]? { get }

    /// Optional default properties to update with this call. If not set, properties are left as they are on the server.
    var default_: [String: String]? { get }

    /// Identity ID to enrich the current session and return a new session. Old session will no longer be usable.
    var id: String { get }
}

public class ApiIdentifyRequest: ApiIdentifyRequestProtocol
{
    public var custom: [String: String]? = [:]
    public var default_: [String: String]? = [:]
    public var id: String

    private enum CodingKeys: String, CodingKey {
        case custom = "custom"
        case default_ = "default"
        case id = "id"
    }
    
    init(
        custom: [String: String] = [:],
        default_: [String: String] = [:],
        id: String
    ) {
        self.custom = custom
        self.default_ = default_
        self.id = id
    }

    var debugDescription: String {
        return "custom: \(custom)default: \(default_)id: \(id)"
    }
}

/// A single live event.
public protocol ApiLiveEventProtocol: Codable {

    /// End time of current event run.
    var activeEndTimeSec: String { get }

    /// Start time of current event run.
    var activeStartTimeSec: String { get }

    /// Description.
    var description: String { get }

    /// The live event identifier.
    var id: String { get }

    /// Name.
    var name: String { get }

    /// Event value.
    var value: String { get }
}

public class ApiLiveEvent: ApiLiveEventProtocol
{
    public var activeEndTimeSec: String
    public var activeStartTimeSec: String
    public var description: String
    public var id: String
    public var name: String
    public var value: String

    private enum CodingKeys: String, CodingKey {
        case activeEndTimeSec = "activeEndTimeSec"
        case activeStartTimeSec = "activeStartTimeSec"
        case description = "description"
        case id = "id"
        case name = "name"
        case value = "value"
    }
    
    init(
        activeEndTimeSec: String,
        activeStartTimeSec: String,
        description: String,
        id: String,
        name: String,
        value: String
    ) {
        self.activeEndTimeSec = activeEndTimeSec
        self.activeStartTimeSec = activeStartTimeSec
        self.description = description
        self.id = id
        self.name = name
        self.value = value
    }

    var debugDescription: String {
        return "activeEndTimeSec: \(activeEndTimeSec)activeStartTimeSec: \(activeStartTimeSec)description: \(description)id: \(id)name: \(name)value: \(value)"
    }
}

/// List of Live events.
public protocol ApiLiveEventListProtocol: Codable {

    /// Live events.
    var liveEvents: [ApiLiveEvent]? { get }
}

public class ApiLiveEventList: ApiLiveEventListProtocol
{
    public var liveEvents: [ApiLiveEvent]? = []

    private enum CodingKeys: String, CodingKey {
        case liveEvents = "liveEvents"
    }
    
    init(
        liveEvents: [ApiLiveEvent] = []
    ) {
        self.liveEvents = liveEvents
    }

    var debugDescription: String {
        return "liveEvents: \(liveEvents)"
    }
}

/// A scheduled message.
public protocol ApiMessageProtocol: Codable {

    /// The time the message was consumed by the identity.
    var consumeTime: String { get }

    /// The time the message was created.
    var createTime: String { get }

    /// A key-value pairs of metadata.
    var metadata: [String: String]? { get }

    /// The time the message was read by the client.
    var readTime: String { get }

    /// The identifier of the schedule.
    var scheduleId: String { get }

    /// The send time for the message.
    var sendTime: String { get }

    /// The message's text.
    var text: String { get }

    /// The time the message was updated.
    var updateTime: String { get }
}

public class ApiMessage: ApiMessageProtocol
{
    public var consumeTime: String
    public var createTime: String
    public var metadata: [String: String]? = [:]
    public var readTime: String
    public var scheduleId: String
    public var sendTime: String
    public var text: String
    public var updateTime: String

    private enum CodingKeys: String, CodingKey {
        case consumeTime = "consumeTime"
        case createTime = "createTime"
        case metadata = "metadata"
        case readTime = "readTime"
        case scheduleId = "scheduleId"
        case sendTime = "sendTime"
        case text = "text"
        case updateTime = "updateTime"
    }
    
    init(
        consumeTime: String,
        createTime: String,
        metadata: [String: String] = [:],
        readTime: String,
        scheduleId: String,
        sendTime: String,
        text: String,
        updateTime: String
    ) {
        self.consumeTime = consumeTime
        self.createTime = createTime
        self.metadata = metadata
        self.readTime = readTime
        self.scheduleId = scheduleId
        self.sendTime = sendTime
        self.text = text
        self.updateTime = updateTime
    }

    var debugDescription: String {
        return "consumeTime: \(consumeTime)createTime: \(createTime)metadata: \(metadata)readTime: \(readTime)scheduleId: \(scheduleId)sendTime: \(sendTime)text: \(text)updateTime: \(updateTime)"
    }
}

/// Properties associated with an identity.
public protocol ApiPropertiesProtocol: Codable {

    /// Event computed properties.
    var computed: [String: String]? { get }

    /// Event custom properties.
    var custom: [String: String]? { get }

    /// Event default properties.
    var default_: [String: String]? { get }
}

public class ApiProperties: ApiPropertiesProtocol
{
    public var computed: [String: String]? = [:]
    public var custom: [String: String]? = [:]
    public var default_: [String: String]? = [:]

    private enum CodingKeys: String, CodingKey {
        case computed = "computed"
        case custom = "custom"
        case default_ = "default"
    }
    
    init(
        computed: [String: String] = [:],
        custom: [String: String] = [:],
        default_: [String: String] = [:]
    ) {
        self.computed = computed
        self.custom = custom
        self.default_ = default_
    }

    var debugDescription: String {
        return "computed: \(computed)custom: \(custom)default: \(default_)"
    }
}

/// A session.
public protocol ApiSessionProtocol: Codable {

    /// Properties associated with this identity.
    var properties: ApiProperties? { get }

    /// Refresh token.
    var refreshToken: String { get }

    /// Token credential.
    var token: String { get }
}

public class ApiSession: ApiSessionProtocol
{
    public var properties: ApiProperties?
    public var refreshToken: String
    public var token: String

    private enum CodingKeys: String, CodingKey {
        case properties = "properties"
        case refreshToken = "refresh_token"
        case token = "token"
    }
    
    init(
        properties: ApiProperties,
        refreshToken: String,
        token: String
    ) {
        self.properties = properties
        self.refreshToken = refreshToken
        self.token = token
    }

    var debugDescription: String {
        return "properties: \(properties)refreshToken: \(refreshToken)token: \(token)"
    }
}

/// Update Properties associated with this identity.
public protocol ApiUpdatePropertiesRequestProtocol: Codable {

    /// Event custom properties.
    var custom: [String: String]? { get }

    /// Event default properties.
    var default_: [String: String]? { get }

    /// Informs the server to recompute the audience membership of the identity.
    var recompute: Bool? { get }
}

public class ApiUpdatePropertiesRequest: ApiUpdatePropertiesRequestProtocol
{
    public var custom: [String: String]? = [:]
    public var default_: [String: String]? = [:]
    public var recompute: Bool?

    private enum CodingKeys: String, CodingKey {
        case custom = "custom"
        case default_ = "default"
        case recompute = "recompute"
    }
    
    init(
        custom: [String: String] = [:],
        default_: [String: String] = [:],
        recompute: Bool
    ) {
        self.custom = custom
        self.default_ = default_
        self.recompute = recompute
    }

    var debugDescription: String {
        return "custom: \(custom)default: \(default_)recompute: \(recompute)"
    }
}

/// 
public protocol ProtobufAnyProtocol: Codable {

    /// 
    var type: String { get }
}

public class ProtobufAny: ProtobufAnyProtocol
{
    public var type: String

    private enum CodingKeys: String, CodingKey {
        case type = "type"
    }
    
    init(
        type: String
    ) {
        self.type = type
    }

    var debugDescription: String {
        return "type: \(type)"
    }
}

/// 
public protocol RpcStatusProtocol: Codable {

    /// 
    var code: Int { get }

    /// 
    var details: [ProtobufAny]? { get }

    /// 
    var message: String { get }
}

public class RpcStatus: RpcStatusProtocol
{
    public var code: Int
    public var details: [ProtobufAny]? = []
    public var message: String

    private enum CodingKeys: String, CodingKey {
        case code = "code"
        case details = "details"
        case message = "message"
    }
    
    init(
        code: Int,
        details: [ProtobufAny] = [],
        message: String
    ) {
        self.code = code
        self.details = details
        self.message = message
    }

    var debugDescription: String {
        return "code: \(code)details: \(details)message: \(message)"
    }
}

/// The low level client for the Satori API.
class ApiClient
{
    public let httpAdapter: HttpAdapterProtocol
    public let timeout: Int

    private(set) var baseUri: URL

    public init(baseUri: URL, httpAdapter: HttpAdapterProtocol, timeout: Int = 10)
    {
        self.baseUri = baseUri
        self.httpAdapter = httpAdapter
        self.timeout = timeout
    }

    /// A healthcheck which load balancers can use to check the service.
    public func SatoriHealthcheck(
        bearerToken: String) async throws -> Void {

        var urlComponents = URLComponents()
        urlComponents.scheme = baseUri.scheme
        urlComponents.host = baseUri.host
        urlComponents.path = "/healthcheck"

        var queryItems = [URLQueryItem]()
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            throw SatoriError.invalidURL
        }

        let method = "GET"
        var headers: [String: String] = [:]
        var header = "Bearer \(bearerToken)"
        headers["Authorization"] = header

        var content: Data? = nil
        let _: EmptyResponse = try await httpAdapter.sendAsync(method: method, uri: url, headers: headers, body: content, timeoutSec: timeout)
    }

    /// A readycheck which load balancers can use to check the service.
    public func SatoriReadycheck(
        bearerToken: String) async throws -> Void {

        var urlComponents = URLComponents()
        urlComponents.scheme = baseUri.scheme
        urlComponents.host = baseUri.host
        urlComponents.path = "/readycheck"

        var queryItems = [URLQueryItem]()
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            throw SatoriError.invalidURL
        }

        let method = "GET"
        var headers: [String: String] = [:]
        var header = "Bearer \(bearerToken)"
        headers["Authorization"] = header

        var content: Data? = nil
        let _: EmptyResponse = try await httpAdapter.sendAsync(method: method, uri: url, headers: headers, body: content, timeoutSec: timeout)
    }

    /// Authenticate against the server.
    public func SatoriAuthenticate(
        basicAuthUsername: String,
        basicAuthPassword: String,
        body: ApiAuthenticateRequest) async throws -> ApiSession {

        var urlComponents = URLComponents()
        urlComponents.scheme = baseUri.scheme
        urlComponents.host = baseUri.host
        urlComponents.path = "/v1/authenticate"

        var queryItems = [URLQueryItem]()
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            throw SatoriError.invalidURL
        }

        let method = "POST"
        var headers: [String: String] = [:]
        if !basicAuthUsername.isEmpty {
            if let credentials = "\(basicAuthUsername):\(basicAuthPassword)".data(using: .utf8)?.base64EncodedString() {
                var header = "Basic \(credentials)"
                headers["Authorization"] = header
            }
        }

        var content: Data? = nil
        let encoder = JSONEncoder()
        do {
            content = try encoder.encode(body)
        } catch {
            print("Error encoding body: \(error)")
        }
        var response: ApiSession = try await httpAdapter.sendAsync(method: method, uri: url, headers: headers, body: content, timeoutSec: timeout)
        return response
    }

    /// Log out a session, invalidate a refresh token, or log out all sessions/refresh tokens for a user.
    public func SatoriAuthenticateLogout(
        bearerToken: String,
        body: ApiAuthenticateLogoutRequest) async throws -> Void {

        var urlComponents = URLComponents()
        urlComponents.scheme = baseUri.scheme
        urlComponents.host = baseUri.host
        urlComponents.path = "/v1/authenticate/logout"

        var queryItems = [URLQueryItem]()
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            throw SatoriError.invalidURL
        }

        let method = "POST"
        var headers: [String: String] = [:]
        var header = "Bearer \(bearerToken)"
        headers["Authorization"] = header

        var content: Data? = nil
        let encoder = JSONEncoder()
        do {
            content = try encoder.encode(body)
        } catch {
            print("Error encoding body: \(error)")
        }
        let _: EmptyResponse = try await httpAdapter.sendAsync(method: method, uri: url, headers: headers, body: content, timeoutSec: timeout)
    }

    /// Refresh a user's session using a refresh token retrieved from a previous authentication request.
    public func SatoriAuthenticateRefresh(
        basicAuthUsername: String,
        basicAuthPassword: String,
        body: ApiAuthenticateRefreshRequest) async throws -> ApiSession {

        var urlComponents = URLComponents()
        urlComponents.scheme = baseUri.scheme
        urlComponents.host = baseUri.host
        urlComponents.path = "/v1/authenticate/refresh"

        var queryItems = [URLQueryItem]()
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            throw SatoriError.invalidURL
        }

        let method = "POST"
        var headers: [String: String] = [:]
        if !basicAuthUsername.isEmpty {
            if let credentials = "\(basicAuthUsername):\(basicAuthPassword)".data(using: .utf8)?.base64EncodedString() {
                var header = "Basic \(credentials)"
                headers["Authorization"] = header
            }
        }

        var content: Data? = nil
        let encoder = JSONEncoder()
        do {
            content = try encoder.encode(body)
        } catch {
            print("Error encoding body: \(error)")
        }
        var response: ApiSession = try await httpAdapter.sendAsync(method: method, uri: url, headers: headers, body: content, timeoutSec: timeout)
        return response
    }

    /// Publish an event for this session.
    public func SatoriEvent(
        bearerToken: String,
        body: ApiEventRequest) async throws -> Void {

        var urlComponents = URLComponents()
        urlComponents.scheme = baseUri.scheme
        urlComponents.host = baseUri.host
        urlComponents.path = "/v1/event"

        var queryItems = [URLQueryItem]()
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            throw SatoriError.invalidURL
        }

        let method = "POST"
        var headers: [String: String] = [:]
        var header = "Bearer \(bearerToken)"
        headers["Authorization"] = header

        var content: Data? = nil
        let encoder = JSONEncoder()
        do {
            content = try encoder.encode(body)
        } catch {
            print("Error encoding body: \(error)")
        }
        let _: EmptyResponse = try await httpAdapter.sendAsync(method: method, uri: url, headers: headers, body: content, timeoutSec: timeout)
    }

    /// Get or list all available experiments for this identity.
    public func SatoriGetExperiments(
        bearerToken: String,
        names: [String]) async throws -> ApiExperimentList {

        var urlComponents = URLComponents()
        urlComponents.scheme = baseUri.scheme
        urlComponents.host = baseUri.host
        urlComponents.path = "/v1/experiment"

        var queryItems = [URLQueryItem]()
        for param in names {
            queryItems.append(URLQueryItem(name: "names", value: param))
        }
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            throw SatoriError.invalidURL
        }

        let method = "GET"
        var headers: [String: String] = [:]
        var header = "Bearer \(bearerToken)"
        headers["Authorization"] = header

        var content: Data? = nil
        var response: ApiExperimentList = try await httpAdapter.sendAsync(method: method, uri: url, headers: headers, body: content, timeoutSec: timeout)
        return response
    }

    /// List all available flags for this identity.
    public func SatoriGetFlags(
        bearerToken: String,
        basicAuthUsername: String,
        basicAuthPassword: String,
        names: [String]) async throws -> ApiFlagList {

        var urlComponents = URLComponents()
        urlComponents.scheme = baseUri.scheme
        urlComponents.host = baseUri.host
        urlComponents.path = "/v1/flag"

        var queryItems = [URLQueryItem]()
        for param in names {
            queryItems.append(URLQueryItem(name: "names", value: param))
        }
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            throw SatoriError.invalidURL
        }

        let method = "GET"
        var headers: [String: String] = [:]
        if !bearerToken.isEmpty {
            var header = "Bearer \(bearerToken)"
            headers["Authorization"] = header
        }
        if !basicAuthUsername.isEmpty {
            if let credentials = "\(basicAuthUsername):\(basicAuthPassword)".data(using: .utf8)?.base64EncodedString() {
                var header = "Basic \(credentials)"
                headers["Authorization"] = header
            }
        }

        var content: Data? = nil
        var response: ApiFlagList = try await httpAdapter.sendAsync(method: method, uri: url, headers: headers, body: content, timeoutSec: timeout)
        return response
    }

    /// Enrich/replace the current session with new identifier.
    public func SatoriIdentify(
        bearerToken: String,
        body: ApiIdentifyRequest) async throws -> ApiSession {

        var urlComponents = URLComponents()
        urlComponents.scheme = baseUri.scheme
        urlComponents.host = baseUri.host
        urlComponents.path = "/v1/identify"

        var queryItems = [URLQueryItem]()
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            throw SatoriError.invalidURL
        }

        let method = "PUT"
        var headers: [String: String] = [:]
        var header = "Bearer \(bearerToken)"
        headers["Authorization"] = header

        var content: Data? = nil
        let encoder = JSONEncoder()
        do {
            content = try encoder.encode(body)
        } catch {
            print("Error encoding body: \(error)")
        }
        var response: ApiSession = try await httpAdapter.sendAsync(method: method, uri: url, headers: headers, body: content, timeoutSec: timeout)
        return response
    }

    /// Delete the caller's identity and associated data.
    public func SatoriDeleteIdentity(
        bearerToken: String) async throws -> Void {

        var urlComponents = URLComponents()
        urlComponents.scheme = baseUri.scheme
        urlComponents.host = baseUri.host
        urlComponents.path = "/v1/identity"

        var queryItems = [URLQueryItem]()
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            throw SatoriError.invalidURL
        }

        let method = "DELETE"
        var headers: [String: String] = [:]
        var header = "Bearer \(bearerToken)"
        headers["Authorization"] = header

        var content: Data? = nil
        let _: EmptyResponse = try await httpAdapter.sendAsync(method: method, uri: url, headers: headers, body: content, timeoutSec: timeout)
    }

    /// List available live events.
    public func SatoriGetLiveEvents(
        bearerToken: String,
        names: [String]) async throws -> ApiLiveEventList {

        var urlComponents = URLComponents()
        urlComponents.scheme = baseUri.scheme
        urlComponents.host = baseUri.host
        urlComponents.path = "/v1/live-event"

        var queryItems = [URLQueryItem]()
        for param in names {
            queryItems.append(URLQueryItem(name: "names", value: param))
        }
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            throw SatoriError.invalidURL
        }

        let method = "GET"
        var headers: [String: String] = [:]
        var header = "Bearer \(bearerToken)"
        headers["Authorization"] = header

        var content: Data? = nil
        var response: ApiLiveEventList = try await httpAdapter.sendAsync(method: method, uri: url, headers: headers, body: content, timeoutSec: timeout)
        return response
    }

    /// Get the list of messages for the identity.
    public func SatoriGetMessageList(
        bearerToken: String,
        limit: Int?,
        forward: Bool?,
        cursor: String?) async throws -> ApiGetMessageListResponse {

        var urlComponents = URLComponents()
        urlComponents.scheme = baseUri.scheme
        urlComponents.host = baseUri.host
        urlComponents.path = "/v1/message"

        var queryItems = [URLQueryItem]()
        if let limit {
            queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        }
        if let forward {
            queryItems.append(URLQueryItem(name: "forward", value: "\(forward)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)))
        }
        if let cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor.lowercased()))
        }
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            throw SatoriError.invalidURL
        }

        let method = "GET"
        var headers: [String: String] = [:]
        var header = "Bearer \(bearerToken)"
        headers["Authorization"] = header

        var content: Data? = nil
        var response: ApiGetMessageListResponse = try await httpAdapter.sendAsync(method: method, uri: url, headers: headers, body: content, timeoutSec: timeout)
        return response
    }

    /// Deletes a message for an identity.
    public func SatoriDeleteMessage(
        bearerToken: String,
        id: String) async throws -> Void {

        var urlComponents = URLComponents()
        urlComponents.scheme = baseUri.scheme
        urlComponents.host = baseUri.host
        urlComponents.path = "/v1/message/{id}"
        urlComponents.path.append(id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)

        var queryItems = [URLQueryItem]()
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            throw SatoriError.invalidURL
        }

        let method = "DELETE"
        var headers: [String: String] = [:]
        var header = "Bearer \(bearerToken)"
        headers["Authorization"] = header

        var content: Data? = nil
        let _: EmptyResponse = try await httpAdapter.sendAsync(method: method, uri: url, headers: headers, body: content, timeoutSec: timeout)
    }

    /// Updates a message for an identity.
    public func SatoriUpdateMessage(
        bearerToken: String,
        id: String,
        body: ApiUpdateMessageRequest) async throws -> Void {

        var urlComponents = URLComponents()
        urlComponents.scheme = baseUri.scheme
        urlComponents.host = baseUri.host
        urlComponents.path = "/v1/message/{id}"
        urlComponents.path.append(id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)

        var queryItems = [URLQueryItem]()
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            throw SatoriError.invalidURL
        }

        let method = "PUT"
        var headers: [String: String] = [:]
        var header = "Bearer \(bearerToken)"
        headers["Authorization"] = header

        var content: Data? = nil
        let encoder = JSONEncoder()
        do {
            content = try encoder.encode(body)
        } catch {
            print("Error encoding body: \(error)")
        }
        let _: EmptyResponse = try await httpAdapter.sendAsync(method: method, uri: url, headers: headers, body: content, timeoutSec: timeout)
    }

    /// List properties associated with this identity.
    public func SatoriListProperties(
        bearerToken: String) async throws -> ApiProperties {

        var urlComponents = URLComponents()
        urlComponents.scheme = baseUri.scheme
        urlComponents.host = baseUri.host
        urlComponents.path = "/v1/properties"

        var queryItems = [URLQueryItem]()
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            throw SatoriError.invalidURL
        }

        let method = "GET"
        var headers: [String: String] = [:]
        var header = "Bearer \(bearerToken)"
        headers["Authorization"] = header

        var content: Data? = nil
        var response: ApiProperties = try await httpAdapter.sendAsync(method: method, uri: url, headers: headers, body: content, timeoutSec: timeout)
        return response
    }

    /// Update identity properties.
    public func SatoriUpdateProperties(
        bearerToken: String,
        body: ApiUpdatePropertiesRequest) async throws -> Void {

        var urlComponents = URLComponents()
        urlComponents.scheme = baseUri.scheme
        urlComponents.host = baseUri.host
        urlComponents.path = "/v1/properties"

        var queryItems = [URLQueryItem]()
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            throw SatoriError.invalidURL
        }

        let method = "PUT"
        var headers: [String: String] = [:]
        var header = "Bearer \(bearerToken)"
        headers["Authorization"] = header

        var content: Data? = nil
        let encoder = JSONEncoder()
        do {
            content = try encoder.encode(body)
        } catch {
            print("Error encoding body: \(error)")
        }
        let _: EmptyResponse = try await httpAdapter.sendAsync(method: method, uri: url, headers: headers, body: content, timeoutSec: timeout)
    }
}