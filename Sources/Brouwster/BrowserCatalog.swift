import AppKit
import BrouwsterCore

struct InstalledBrowser: Identifiable, Hashable {
    var bundleIdentifier: String
    var name: String
    var applicationURL: URL
    var profiles: [BrowserProfile]

    var id: String { bundleIdentifier }
    var icon: NSImage { NSWorkspace.shared.icon(forFile: applicationURL.path) }
}

/// Finds the browsers installed on this Mac via Launch Services.
enum BrowserCatalog {
    static func scan() -> [InstalledBrowser] {
        let ownID = Bundle.main.bundleIdentifier
        let apps = NSWorkspace.shared.urlsForApplications(toOpen: URL(string: "https://example.com")!)
        var seen = Set<String>()
        return apps
            .compactMap { url -> InstalledBrowser? in
                guard let bundle = Bundle(url: url), let id = bundle.bundleIdentifier,
                      id != ownID, seen.insert(id).inserted else { return nil }
                let name = (bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
                    ?? (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String)
                    ?? url.deletingPathExtension().lastPathComponent
                let profiles = ChromiumBrowsers.userDataDirectory(forBundleIdentifier: id)
                    .map { ChromiumProfileScanner().profiles(inUserDataDirectory: $0) } ?? []
                return InstalledBrowser(bundleIdentifier: id, name: name, applicationURL: url, profiles: profiles)
            }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
