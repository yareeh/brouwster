import Foundation

/// Persists the routing config as JSON.
public struct ConfigStore: Sendable {
    public var fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    /// `~/Library/Application Support/Brouwster/config.json`
    public static var standard: ConfigStore {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return ConfigStore(fileURL: support.appendingPathComponent("Brouwster/config.json"))
    }

    public func load() -> RoutingConfig {
        guard let data = try? Data(contentsOf: fileURL),
              let config = try? JSONDecoder().decode(RoutingConfig.self, from: data) else { return RoutingConfig() }
        return config
    }

    public func save(_ config: RoutingConfig) throws {
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(config).write(to: fileURL, options: .atomic)
    }
}
