import Foundation

/// Removes tracking query parameters from URLs.
public struct URLCleaner: Sendable {
    public init() {}

    public func clean(_ url: URL) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let items = components.queryItems else { return url }
        let kept = items.filter { !$0.name.lowercased().hasPrefix("utm_") }
        components.queryItems = kept.isEmpty ? nil : kept
        return components.url ?? url
    }
}
