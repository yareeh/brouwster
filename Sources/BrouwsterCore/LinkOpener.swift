import AppKit

/// Cleans a link, picks its browser target from the routing config and hands the link over.
@MainActor
public struct LinkOpener {
    /// Used when no rule matches, no default is set, or the chosen browser is not installed.
    public static let fallback = BrowserTarget(bundleIdentifier: "com.apple.Safari")

    private let cleaner = URLCleaner()

    public init() {}

    public func open(_ url: URL, config: RoutingConfig) {
        let cleaned = cleaner.clean(url)
        let routed = Router(config: config).target(for: cleaned) ?? Self.fallback
        let resolved = [routed, Self.fallback].lazy
            .compactMap { target in Self.applicationURL(for: target).map { (target, $0) } }
            .first
        guard let (target, appURL) = resolved else { return }
        switch LaunchPlan(target: target, applicationURL: appURL, url: cleaned) {
        case let .open(url, application):
            NSWorkspace.shared.open([url], withApplicationAt: application, configuration: NSWorkspace.OpenConfiguration())
        case let .run(executable, arguments):
            let process = Process()
            process.executableURL = URL(fileURLWithPath: executable)
            process.arguments = arguments
            try? process.run()
        }
    }

    private static func applicationURL(for target: BrowserTarget) -> URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: target.bundleIdentifier)
    }
}
