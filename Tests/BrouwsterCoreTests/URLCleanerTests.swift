import Foundation
import Testing
import BrouwsterCore

@Suite struct URLCleanerTests {
    let cleaner = URLCleaner()

    @Test func removesUtmParametersAndKeepsOthers() {
        let url = URL(string: "https://example.com/a?id=42&utm_source=news&utm_medium=email")!
        #expect(cleaner.clean(url).absoluteString == "https://example.com/a?id=42")
    }
}
