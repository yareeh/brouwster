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

    @Test(arguments: [
        ("https://www.linkedin.com/posts/someone_activity-123?trk=public_post&rcm=ACoAA&lipi=urn%3Ali",
         "https://www.linkedin.com/posts/someone_activity-123"),
        ("https://www.linkedin.com/jobs/view/42?refId=abc&trackingId=xyz&currentJobId=42",
         "https://www.linkedin.com/jobs/view/42?currentJobId=42"),
        ("https://x.com/user/status/1?s=20&t=AbCd", "https://x.com/user/status/1"),
        ("https://twitter.com/user/status/1?ref_src=twsrc%5Etfw", "https://twitter.com/user/status/1"),
        ("https://www.instagram.com/p/Cxyz/?igsh=MWQ1ZGUxMzBkMA==", "https://www.instagram.com/p/Cxyz/"),
        ("https://www.facebook.com/share/p/abc/?mibextid=WC7FNe&rdid=xyz", "https://www.facebook.com/share/p/abc/"),
        ("https://www.threads.net/@user/post/abc?xmt=AQGz", "https://www.threads.net/@user/post/abc"),
        ("https://youtu.be/dQw4w9WgXcQ?si=abcDEF&t=42", "https://youtu.be/dQw4w9WgXcQ?t=42"),
        ("https://www.youtube.com/watch?v=dQw4w9WgXcQ&si=abc&pp=ygUE", "https://www.youtube.com/watch?v=dQw4w9WgXcQ"),
        ("https://open.spotify.com/track/abc?si=123&context=x", "https://open.spotify.com/track/abc?context=x"),
        ("https://www.tiktok.com/@u/video/1?is_from_webapp=1&sender_device=pc&_r=1&_t=8abc",
         "https://www.tiktok.com/@u/video/1"),
        ("https://www.reddit.com/r/swift/comments/abc/?share_id=xyz&rdt=123", "https://www.reddit.com/r/swift/comments/abc/"),
        ("https://www.nytimes.com/2026/10/01/tech/a.html?smid=nytcore-ios-share&smtyp=cur&unlocked_article_code=1.x",
         "https://www.nytimes.com/2026/10/01/tech/a.html?unlocked_article_code=1.x"),
        ("https://www.theguardian.com/world/2026/a?CMP=share_btn_link", "https://www.theguardian.com/world/2026/a"),
        ("https://www.washingtonpost.com/world/2026/a/?itid=hp-top", "https://www.washingtonpost.com/world/2026/a/"),
        ("https://www.bbc.com/news/a?at_medium=RSS&at_campaign=rss&ns_source=x", "https://www.bbc.com/news/a"),
        ("https://www.lemonde.fr/a.html?xtor=RSS-3208", "https://www.lemonde.fr/a.html"),
        ("https://www.wsj.com/articles/a?mod=hp_lead_pos1&st=giftToken", "https://www.wsj.com/articles/a?st=giftToken"),
        ("https://www.bloomberg.com/news/a?srnd=homepage&leadSource=uverify", "https://www.bloomberg.com/news/a"),
        ("https://www.ft.com/content/a?ftcamp=engage&segmentId=abc&accessToken=keep",
         "https://www.ft.com/content/a?accessToken=keep"),
        ("https://www.telegraph.co.uk/news/a/?ito=social", "https://www.telegraph.co.uk/news/a/"),
    ])
    func removesPlatformSpecificTrackers(input: String, expected: String) {
        #expect(cleaner.clean(URL(string: input)!).absoluteString == expected)
    }

    @Test func keepsPlatformSpecificNamesOnOtherHosts() {
        let url = URL(string: "https://example.com/search?s=swift&t=10&si=1&mod=a")!
        #expect(cleaner.clean(url) == url)
    }

    @Test func doesNotTreatLookalikeHostAsPlatform() {
        let url = URL(string: "https://notx.com/a?s=20")!
        #expect(cleaner.clean(url) == url)
    }

    @Test func leavesUrlWithoutTrackersUntouched() {
        let url = URL(string: "https://example.com/search?q=a%20b&page=2")!
        #expect(cleaner.clean(url) == url)
    }
}
