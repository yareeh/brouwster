import Foundation
import Testing
import BrouwsterCore

@Suite struct LaunchPlanTests {
    let chromeApp = URL(fileURLWithPath: "/Applications/Google Chrome.app")
    let page = URL(string: "https://www.linkedin.com/feed/")!

    @Test func opensUrlDirectlyInAppWithoutProfile() {
        let plan = LaunchPlan(target: BrowserTarget(bundleIdentifier: "com.google.Chrome"), applicationURL: chromeApp, url: page)
        #expect(plan == .open(url: page, application: chromeApp))
    }

    @Test func passesProfileDirectoryAsLaunchArgument() {
        let target = BrowserTarget(bundleIdentifier: "com.google.Chrome", profileDirectory: "Profile 1")
        let plan = LaunchPlan(target: target, applicationURL: chromeApp, url: page)
        #expect(plan == .run(executable: "/usr/bin/open", arguments: [
            "-n", "-a", "/Applications/Google Chrome.app", "--args",
            "--profile-directory=Profile 1", "https://www.linkedin.com/feed/",
        ]))
    }
}
