import Foundation

/// A browser application, optionally narrowed to one of its profiles.
public struct BrowserTarget: Codable, Hashable, Sendable {
    public var bundleIdentifier: String
    /// Chromium profile directory name such as "Default" or "Profile 1".
    public var profileDirectory: String?

    public init(bundleIdentifier: String, profileDirectory: String? = nil) {
        self.bundleIdentifier = bundleIdentifier
        self.profileDirectory = profileDirectory
    }
}

/// Sends `domain` and all of its subdomains to `target`.
public struct DomainRule: Codable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var domain: String
    public var target: BrowserTarget

    public init(id: UUID = UUID(), domain: String, target: BrowserTarget) {
        self.id = id
        self.domain = domain
        self.target = target
    }
}

public struct RoutingConfig: Codable, Hashable, Sendable {
    public var rules: [DomainRule]
    public var defaultTarget: BrowserTarget?

    public init(rules: [DomainRule] = [], defaultTarget: BrowserTarget? = nil) {
        self.rules = rules
        self.defaultTarget = defaultTarget
    }
}
