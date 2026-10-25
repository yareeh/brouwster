import Foundation
import Testing
import BrouwsterCore

@Suite struct ConfigStoreTests {
    let file = FileManager.default.temporaryDirectory
        .appendingPathComponent("ConfigStoreTests-\(UUID().uuidString)")
        .appendingPathComponent("config.json")

    @Test func loadsEmptyConfigWhenNothingSaved() {
        #expect(ConfigStore(fileURL: file).load() == RoutingConfig())
    }

    @Test func savedConfigLoadsBackIdentical() throws {
        let config = RoutingConfig(
            rules: [DomainRule(domain: "linkedin.com", target: BrowserTarget(bundleIdentifier: "com.google.Chrome", profileDirectory: "Profile 1"))],
            defaultTarget: BrowserTarget(bundleIdentifier: "org.mozilla.firefox")
        )
        try ConfigStore(fileURL: file).save(config)
        #expect(ConfigStore(fileURL: file).load() == config)
    }
}
