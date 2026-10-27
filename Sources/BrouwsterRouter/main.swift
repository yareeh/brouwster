import AppKit
import BrouwsterCore

/// Receives links as the default browser and passes them on. Has no UI.
@MainActor
final class RouterDelegate: NSObject, NSApplicationDelegate {
    private let store = ConfigStore.standard
    private let opener = LinkOpener()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Launched directly rather than to open a link: show the settings app that embeds us.
        if notification.userInfo?[NSApplication.launchIsDefaultUserInfoKey] as? Bool ?? true {
            openSettingsApp()
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        // Reload per batch so rule changes made in the settings app apply immediately.
        let config = store.load()
        urls.forEach { opener.open($0, config: config) }
    }

    private func openSettingsApp() {
        // Brouwster.app/Contents/Helpers/Brouwster Router.app
        let settingsApp = Bundle.main.bundleURL
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        guard settingsApp.pathExtension == "app" else { return }
        NSWorkspace.shared.openApplication(at: settingsApp, configuration: NSWorkspace.OpenConfiguration())
    }
}

let app = NSApplication.shared
let delegate = RouterDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
