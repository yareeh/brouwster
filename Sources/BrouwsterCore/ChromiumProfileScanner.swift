import Foundation

public struct BrowserProfile: Codable, Hashable, Identifiable, Sendable {
    /// Directory name under the browser's user data directory, passed as `--profile-directory`.
    public var directory: String
    public var name: String
    public var email: String?

    public var id: String { directory }

    public init(directory: String, name: String, email: String?) {
        self.directory = directory
        self.name = name
        self.email = email
    }
}

/// Reads profiles of Chromium based browsers (Chrome, Edge, Brave, Vivaldi...) from their `Local State` file.
public struct ChromiumProfileScanner: Sendable {
    private struct LocalState: Decodable {
        struct Profile: Decodable { var info_cache: [String: Info] }
        struct Info: Decodable {
            var name: String?
            var user_name: String?
        }
        var profile: Profile
    }

    public init() {}

    public func profiles(inUserDataDirectory directory: URL) -> [BrowserProfile] {
        let file = directory.appendingPathComponent("Local State")
        guard let data = try? Data(contentsOf: file),
              let state = try? JSONDecoder().decode(LocalState.self, from: data) else { return [] }
        return state.profile.info_cache
            .map { key, info in
                BrowserProfile(
                    directory: key,
                    name: info.name.flatMap { $0.isEmpty ? nil : $0 } ?? key,
                    email: info.user_name.flatMap { $0.isEmpty ? nil : $0 }
                )
            }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
