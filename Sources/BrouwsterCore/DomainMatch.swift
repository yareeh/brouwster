import Foundation

enum DomainMatch {
    /// True when `host` is `domain` itself or any subdomain of it.
    static func host(_ host: String, isWithin domain: String) -> Bool {
        let host = normalize(host)
        let domain = normalize(domain)
        guard !domain.isEmpty else { return false }
        return host == domain || host.hasSuffix("." + domain)
    }

    static func normalize(_ value: String) -> String {
        var value = value.trimmingCharacters(in: .whitespaces).lowercased()
        if value.hasPrefix("*.") { value.removeFirst(2) }
        while value.hasSuffix(".") { value.removeLast() }
        return value
    }
}
