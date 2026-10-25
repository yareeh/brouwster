import Foundation

/// Picks the browser target for a URL from the routing rules.
public struct Router: Sendable {
    public var config: RoutingConfig

    public init(config: RoutingConfig) {
        self.config = config
    }

    /// The target of the most specific matching rule, else the default target.
    public func target(for url: URL) -> BrowserTarget? {
        let host = url.host ?? ""
        return config.rules
            .filter { DomainMatch.host(host, isWithin: $0.domain) }
            .max { DomainMatch.normalize($0.domain).count < DomainMatch.normalize($1.domain).count }?
            .target
            ?? config.defaultTarget
    }
}
