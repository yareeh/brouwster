import Foundation

/// Browser engines whose profiles Brouwster can scan and target.
public enum BrowserFamily: Sendable {
    case chromium
    case firefox

    /// Bundle identifier → family and profile data directory relative to `~/Library/Application Support`.
    static let known: [String: (family: BrowserFamily, path: String)] = [
        "com.google.Chrome": (.chromium, "Google/Chrome"),
        "com.google.Chrome.beta": (.chromium, "Google/Chrome Beta"),
        "com.google.Chrome.dev": (.chromium, "Google/Chrome Dev"),
        "com.google.Chrome.canary": (.chromium, "Google/Chrome Canary"),
        "org.chromium.Chromium": (.chromium, "Chromium"),
        "com.microsoft.edgemac": (.chromium, "Microsoft Edge"),
        "com.microsoft.edgemac.Beta": (.chromium, "Microsoft Edge Beta"),
        "com.microsoft.edgemac.Dev": (.chromium, "Microsoft Edge Dev"),
        "com.brave.Browser": (.chromium, "BraveSoftware/Brave-Browser"),
        "com.vivaldi.Vivaldi": (.chromium, "Vivaldi"),
        "org.mozilla.firefox": (.firefox, "Firefox"),
        "org.mozilla.firefoxdeveloperedition": (.firefox, "Firefox"),
        "org.mozilla.nightly": (.firefox, "Firefox"),
        "app.zen-browser.zen": (.firefox, "zen"),
        "io.gitlab.librewolf-community": (.firefox, "librewolf"),
        "net.waterfox.waterfox": (.firefox, "Waterfox"),
    ]

    public init?(bundleIdentifier: String) {
        guard let entry = Self.known[bundleIdentifier] else { return nil }
        self = entry.family
    }

    /// Profiles of the browser with this bundle identifier, empty when it has none Brouwster knows of.
    public static func profiles(forBundleIdentifier id: String) -> [BrowserProfile] {
        guard let entry = known[id] else { return [] }
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let directory = support.appendingPathComponent(entry.path)
        switch entry.family {
        case .chromium: return ChromiumProfileScanner().profiles(inUserDataDirectory: directory)
        case .firefox: return FirefoxProfileScanner().profiles(inProfilesDirectory: directory)
        }
    }

    func profileArguments(_ profile: String) -> [String] {
        switch self {
        case .chromium: ["--profile-directory=\(profile)"]
        case .firefox: ["-P", profile]
        }
    }
}
