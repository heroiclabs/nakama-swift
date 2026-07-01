import Foundation
@testable
import Nakama

enum TestConfig {
    static func makeClient(trace: Bool = false) -> GrpcClient {
        let url = URL(string: env("NAKAMA_URL", "http://127.0.0.1:7349"))!
        let ssl = url.scheme == "https" || url.scheme == "grpcs"
        return GrpcClient(
            serverKey: env("NAKAMA_KEY", "defaultkey"),
            host: url.host ?? "127.0.0.1",
            port: url.port ?? 7349,
            ssl: ssl,
            trace: trace
        )
    }

    private static func env(_ key: String, _ fallback: String) -> String {
        let value = ProcessInfo.processInfo.environment[key]
        return value?.isEmpty == false ? value! : fallback
    }
}
