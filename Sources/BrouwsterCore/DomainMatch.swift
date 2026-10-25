import Foundation

enum DomainMatch {
    /// True when `host` is `domain` itself or any subdomain of it.
    static func host(_ host: String, isWithin domain: String) -> Bool {
        let host = normalize(host)
        let domain = normalize(domain)
        guard !domain.isEmpty else { return false }
        return host == domain || host.hasSuffix("." + domain)
    }

    /// Reduces user input like "*.Example.com", "https://www.example.com/x" or "example.com/" to a bare host.
    static func normalize(_ value: String) -> String {
        var value = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let schemeEnd = value.range(of: "://") { value = String(value[schemeEnd.upperBound...]) }
        if let pathStart = value.firstIndex(where: { "/?#".contains($0) }) { value = String(value[..<pathStart]) }
        if value.hasPrefix("*.") { value.removeFirst(2) }
        if value.hasPrefix("www.") { value.removeFirst(4) }
        while value.hasSuffix(".") { value.removeLast() }
        return value
    }
}
