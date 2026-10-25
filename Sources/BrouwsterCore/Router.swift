import Foundation

/// Picks the browser target for a URL from the routing rules.
public struct Router: Sendable {
    public var config: RoutingConfig

    public init(config: RoutingConfig) {
        self.config = config
    }

    public func target(for url: URL) -> BrowserTarget? {
        let host = url.host ?? ""
        return config.rules.first { DomainMatch.host(host, isWithin: $0.domain) }?.target
            ?? config.defaultTarget
    }
}
