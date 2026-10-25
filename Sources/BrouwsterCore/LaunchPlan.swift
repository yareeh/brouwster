import Foundation

/// How to hand a URL over to a browser target.
public enum LaunchPlan: Equatable, Sendable {
    /// Open the URL with the application via NSWorkspace.
    case open(url: URL, application: URL)
    /// Run a process; used when launch arguments such as a profile are needed.
    case run(executable: String, arguments: [String])

    public init(target: BrowserTarget, applicationURL: URL, url: URL) {
        guard let profile = target.profileDirectory,
              let family = BrowserFamily(bundleIdentifier: target.bundleIdentifier) else {
            self = .open(url: url, application: applicationURL)
            return
        }
        self = .run(
            executable: "/usr/bin/open",
            arguments: ["-n", "-a", applicationURL.path, "--args"] + family.profileArguments(profile) + [url.absoluteString]
        )
    }
}
