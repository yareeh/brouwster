import AppKit
import BrouwsterCore
import Observation

@MainActor @Observable
final class AppModel {
    private(set) var browsers: [InstalledBrowser] = []
    private(set) var isDefaultBrowser = false
    var config: RoutingConfig {
        didSet { try? store.save(config) }
    }

    private let store: ConfigStore
    private let cleaner = URLCleaner()
    private let fallback = LinkOpener.fallback

    static let routerBundleIdentifier = "yareeh.brouwster.router"
    /// The embedded router; missing when run outside the app bundle, e.g. with `swift run`.
    var routerURL: URL? {
        let url = Bundle.main.bundleURL.appendingPathComponent("Contents/Helpers/Brouwster Router.app")
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    init(store: ConfigStore = .standard) {
        self.store = store
        config = store.load()
        rescan()
    }

    func rescan() {
        browsers = BrowserCatalog.scan()
        refreshDefaultBrowserStatus()
    }

    // MARK: Routing

    func preview(_ text: String) -> (cleaned: URL, target: BrowserTarget?)? {
        guard let url = URL(string: text.trimmingCharacters(in: .whitespaces)), url.host != nil else { return nil }
        let cleaned = cleaner.clean(url)
        return (cleaned, Router(config: config).target(for: cleaned))
    }

    // MARK: Rules

    func addRule() {
        let target = config.defaultTarget ?? browsers.first.map { BrowserTarget(bundleIdentifier: $0.bundleIdentifier) } ?? fallback
        config.rules.append(DomainRule(domain: "", target: target))
    }

    func removeRule(_ id: DomainRule.ID) {
        config.rules.removeAll { $0.id == id }
    }

    // MARK: Targets

    /// Every selectable target: each browser, plus each of its profiles.
    var targets: [BrowserTarget] {
        browsers.flatMap { browser in
            [BrowserTarget(bundleIdentifier: browser.bundleIdentifier)]
                + browser.profiles.map { BrowserTarget(bundleIdentifier: browser.bundleIdentifier, profileDirectory: $0.directory) }
        }
    }

    func label(for target: BrowserTarget) -> String {
        guard let browser = browsers.first(where: { $0.bundleIdentifier == target.bundleIdentifier }) else {
            return "Not installed: \(target.bundleIdentifier)"
        }
        guard let directory = target.profileDirectory else {
            return browser.profiles.isEmpty ? browser.name : "\(browser.name) — last used profile"
        }
        guard let profile = browser.profiles.first(where: { $0.directory == directory }) else {
            return "\(browser.name) — missing profile \(directory)"
        }
        return "\(browser.name) — \(profile.name)" + (profile.email.map { " (\($0))" } ?? "")
    }

    // MARK: System default browser

    func refreshDefaultBrowserStatus() {
        let handler = NSWorkspace.shared.urlForApplication(toOpen: URL(string: "https://example.com")!)
        isDefaultBrowser = handler.flatMap { Bundle(url: $0)?.bundleIdentifier } == Self.routerBundleIdentifier
    }

    func makeDefaultBrowser() {
        guard let routerURL else { return }
        NSWorkspace.shared.setDefaultApplication(at: routerURL, toOpenURLsWithScheme: "http") { _ in
            Task { @MainActor in self.refreshDefaultBrowserStatus() }
        }
    }
}
