import Foundation

/// Removes tracking query parameters from URLs.
public struct URLCleaner: Sendable {
    static let globalPrefixes = ["utm_"]
    static let globalNames: Set<String> = [
        "fbclid", "gclid", "dclid", "msclkid", "mc_eid", "mc_cid", "_hsenc", "_hsmi",
        "igshid", "yclid", "twclid", "ttclid", "li_fat_id", "wickedid", "oly_enc_id", "vero_id",
    ]

    public init() {}

    public func clean(_ url: URL) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let items = components.queryItems else { return url }
        let kept = items.filter { !isTracker($0.name) }
        guard kept.count != items.count else { return url }
        components.queryItems = kept.isEmpty ? nil : kept
        return components.url ?? url
    }

    private func isTracker(_ name: String) -> Bool {
        let name = name.lowercased()
        return Self.globalNames.contains(name) || Self.globalPrefixes.contains { name.hasPrefix($0) }
    }
}
