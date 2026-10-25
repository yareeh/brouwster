import Foundation

/// Reads profiles of Firefox based browsers from `profiles.ini`.
/// The profile name is used as `directory` because Firefox selects profiles with `-P <name>`.
public struct FirefoxProfileScanner: Sendable {
    public init() {}

    public func profiles(inProfilesDirectory directory: URL) -> [BrowserProfile] {
        guard let text = try? String(contentsOf: directory.appendingPathComponent("profiles.ini"), encoding: .utf8) else {
            return []
        }
        var names: [String] = []
        var inProfileSection = false
        for line in text.split(whereSeparator: \.isNewline).map({ $0.trimmingCharacters(in: .whitespaces) }) {
            if line.hasPrefix("[") {
                inProfileSection = line.hasPrefix("[Profile")
            } else if inProfileSection, line.hasPrefix("Name=") {
                names.append(String(line.dropFirst("Name=".count)))
            }
        }
        return names
            .map { BrowserProfile(directory: $0, name: $0, email: nil) }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
