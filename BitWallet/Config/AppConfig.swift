import Foundation

enum AppConfig {
    // Prefer LocalConfig when available, else fallback values
    static let apiBaseURL: String = {
        if let local = LocalConfig.apiBaseURL, !local.isEmpty {
            return local
        }
        // Final fallback (ensure it matches your production base path)
        return "https://api.apilayer.com/fixer"
    }()

    static let apiToken: String = {
        if let local = LocalConfig.apiToken, !local.isEmpty {
            return local
        }
        // Final fallback; keep empty by default
        return ""
    }()
}
