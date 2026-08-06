import Foundation
@testable
import Satori

enum TestConfig {
    static func makeClient(autoRefreshSession: Bool = true) -> HttpClient {
        let url = URL(string: env("SATORI_URL", "http://127.0.0.1:7450"))!
        return HttpClient(
            scheme: url.scheme ?? "http",
            host: url.host ?? "127.0.0.1",
            port: url.port ?? 7450,
            apiKey: apiKey,
            autoRefreshSession: autoRefreshSession
        )
    }

    // Fetch the key either from environment, or use satori console
    static let apiKey: String = {
        if let key = ProcessInfo.processInfo.environment["SATORI_KEY"], !key.isEmpty {
            return key
        }
        return bootstrapFromConsole()
    }()

    private static func bootstrapFromConsole() -> String {
        let base = env("SATORI_CONSOLE_URL", "http://127.0.0.1:7451")
        let auth = "Basic " + Data("admin@satoriserver.com:satoripassword".utf8).base64EncodedString()

        _ = console(base, "/v1/console/data/default", "POST", auth)
        _ = console(base, "/v1/console/data/sampledata", "POST", auth)

        // The console masks key values in listings; rotating returns a usable value.
        guard let data = console(base, "/v1/console/apikey/default/rotate", "POST", auth),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let value = json["value"] as? String, !value.isEmpty
        else {
            fatalError("Satori console bootstrap failed at \(base). Set SATORI_KEY to override.")
        }
        return value
    }

    private static func console(_ base: String, _ path: String, _ method: String, _ auth: String) -> Data? {
        var req = URLRequest(url: URL(string: base + path)!)
        req.httpMethod = method
        req.setValue(auth, forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 10

        let sem = DispatchSemaphore(value: 0)
        var body: Data?
        URLSession.shared.dataTask(with: req) { data, _, _ in
            body = data
            sem.signal()
        }.resume()

        if sem.wait(timeout: .now() + 10) == .timedOut {
            return nil
        }
        return body
    }

    private static func env(_ key: String, _ fallback: String) -> String {
        let value = ProcessInfo.processInfo.environment[key]
        return value?.isEmpty == false ? value! : fallback
    }
}
