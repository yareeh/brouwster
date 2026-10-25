import Foundation

/// Chromium based browsers whose profiles can be targeted with `--profile-directory`.
public enum ChromiumBrowsers {
    /// Bundle identifier → user data directory relative to `~/Library/Application Support`.
    public static let userDataPaths: [String: String] = [
        "com.google.Chrome": "Google/Chrome",
        "com.google.Chrome.beta": "Google/Chrome Beta",
        "com.google.Chrome.dev": "Google/Chrome Dev",
        "com.google.Chrome.canary": "Google/Chrome Canary",
        "org.chromium.Chromium": "Chromium",
        "com.microsoft.edgemac": "Microsoft Edge",
        "com.microsoft.edgemac.Beta": "Microsoft Edge Beta",
        "com.microsoft.edgemac.Dev": "Microsoft Edge Dev",
        "com.brave.Browser": "BraveSoftware/Brave-Browser",
        "com.vivaldi.Vivaldi": "Vivaldi",
    ]

    public static func userDataDirectory(forBundleIdentifier id: String) -> URL? {
        guard let path = userDataPaths[id] else { return nil }
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return support.appendingPathComponent(path)
    }
}
