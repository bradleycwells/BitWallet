import Foundation

enum LocalConfig {
    private static func dictionary() -> [String: Any]? {
        // Look up LocalConfig.plist in the app bundle
        guard let url = Bundle.main.url(forResource: "LocalConfig", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            return nil
        }
        return dict
    }

    static var apiBaseURL: String? {
        dictionary()?["API_BASE_URL"] as? String
    }

    static var apiToken: String? {
        dictionary()?["API_TOKEN"] as? String
    }
}
