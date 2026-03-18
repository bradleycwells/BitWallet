import Foundation

enum AppConfig {
    // Prefer LocalConfig when available, else fallback values
    static let apiBaseURL: String = {
        if let local = LocalConfig.apiBaseURL, !local.isEmpty {
            return local
        }
        // Use environment variable if present
        if let env = ProcessInfo.processInfo.environment["BASE_URL"], !env.isEmpty {
            return env
        }
        // No fallback; fail if not set
        fatalError("BASE_URL not set in LocalConfig or environment")
    }()

    static let apiToken: String = {
        if let local = LocalConfig.apiToken, !local.isEmpty {
            return local
        }
        if let env = ProcessInfo.processInfo.environment["API_TOKEN"], !env.isEmpty {
            return env
        }
        // No fallback; fail if not set
        fatalError("API_TOKEN not set in LocalConfig or environment")
    }()
}
