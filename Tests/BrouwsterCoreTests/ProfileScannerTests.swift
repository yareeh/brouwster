import Foundation
import Testing
import BrouwsterCore

@Suite struct ProfileScannerTests {
    let dataDirectory: URL

    init() throws {
        dataDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ProfileScannerTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dataDirectory, withIntermediateDirectories: true)
    }

    func writeLocalState(_ json: String) throws {
        try Data(json.utf8).write(to: dataDirectory.appendingPathComponent("Local State"))
    }

    @Test func readsProfilesSortedByDisplayName() throws {
        try writeLocalState("""
        {"profile": {"info_cache": {
            "Default": {"name": "Personal", "user_name": "me@gmail.com"},
            "Profile 1": {"name": "Work", "user_name": "me@work.fi"},
            "Profile 7": {"name": "Admin", "user_name": ""}
        }}}
        """)
        let profiles = ChromiumProfileScanner().profiles(inUserDataDirectory: dataDirectory)
        #expect(profiles == [
            BrowserProfile(directory: "Profile 7", name: "Admin", email: nil),
            BrowserProfile(directory: "Default", name: "Personal", email: "me@gmail.com"),
            BrowserProfile(directory: "Profile 1", name: "Work", email: "me@work.fi"),
        ])
    }

    @Test func fallsBackToDirectoryNameWhenProfileHasNoName() throws {
        try writeLocalState(#"{"profile": {"info_cache": {"Profile 3": {}}}}"#)
        let profiles = ChromiumProfileScanner().profiles(inUserDataDirectory: dataDirectory)
        #expect(profiles == [BrowserProfile(directory: "Profile 3", name: "Profile 3", email: nil)])
    }

    @Test func returnsNoProfilesForMissingOrBrokenLocalState() throws {
        #expect(ChromiumProfileScanner().profiles(inUserDataDirectory: dataDirectory).isEmpty)
        try writeLocalState("not json")
        #expect(ChromiumProfileScanner().profiles(inUserDataDirectory: dataDirectory).isEmpty)
    }
}
