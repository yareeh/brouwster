import Foundation
import Testing
import BrouwsterCore

@Suite struct RouterTests {
    let chromeWork = BrowserTarget(bundleIdentifier: "com.google.Chrome", profileDirectory: "Profile 1")
    let edge = BrowserTarget(bundleIdentifier: "com.microsoft.edgemac", profileDirectory: nil)
    let safari = BrowserTarget(bundleIdentifier: "com.apple.Safari", profileDirectory: nil)

    func route(_ url: String, rules: [DomainRule], default fallback: BrowserTarget? = nil) -> BrowserTarget? {
        Router(config: RoutingConfig(rules: rules, defaultTarget: fallback)).target(for: URL(string: url)!)
    }

    @Test(arguments: [
        "https://linkedin.com/feed",
        "https://www.linkedin.com/in/someone",
        "https://fi.linkedin.com/jobs",
        "https://WWW.LinkedIn.com/",
    ])
    func domainRuleMatchesDomainAndSubdomains(url: String) {
        #expect(route(url, rules: [DomainRule(domain: "linkedin.com", target: chromeWork)]) == chromeWork)
    }

    @Test(arguments: ["https://notlinkedin.com/", "https://linkedin.com.evil.io/"])
    func domainRuleIgnoresLookalikeHosts(url: String) {
        #expect(route(url, rules: [DomainRule(domain: "linkedin.com", target: chromeWork)], default: safari) == safari)
    }
}
