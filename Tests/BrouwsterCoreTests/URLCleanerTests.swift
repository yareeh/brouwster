import Foundation
import Testing
import BrouwsterCore

@Suite struct URLCleanerTests {
    let cleaner = URLCleaner()

    @Test func removesUtmParametersAndKeepsOthers() {
        let url = URL(string: "https://example.com/a?id=42&utm_source=news&utm_medium=email")!
        #expect(cleaner.clean(url).absoluteString == "https://example.com/a?id=42")
    }

    @Test(arguments: [
        "fbclid", "gclid", "dclid", "msclkid", "mc_eid", "mc_cid", "_hsenc", "_hsmi",
        "igshid", "yclid", "twclid", "ttclid", "li_fat_id", "wickedid", "oly_enc_id", "vero_id",
    ])
    func removesGlobalClickIdentifiers(name: String) {
        let url = URL(string: "https://example.com/?q=swift&\(name)=abc123")!
        #expect(cleaner.clean(url).absoluteString == "https://example.com/?q=swift")
    }

    @Test func dropsQueryEntirelyWhenOnlyTrackersRemain() {
        let url = URL(string: "https://example.com/path?fbclid=x#section")!
        #expect(cleaner.clean(url).absoluteString == "https://example.com/path#section")
    }

    @Test func leavesUrlWithoutTrackersUntouched() {
        let url = URL(string: "https://example.com/search?q=a%20b&page=2")!
        #expect(cleaner.clean(url) == url)
    }
}
