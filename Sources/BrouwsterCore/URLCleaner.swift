import Foundation

/// Removes tracking query parameters from URLs.
public struct URLCleaner: Sendable {
    struct Rule: Sendable {
        /// Domains the rule applies to (including subdomains); empty means every host.
        var domains: [String] = []
        var names: Set<String> = []
        var prefixes: [String] = []
    }

    static let rules: [Rule] = [
        Rule(
            names: [
                "fbclid", "gclid", "dclid", "gbraid", "wbraid", "msclkid", "mc_eid", "mc_cid",
                "_hsenc", "_hsmi", "igshid", "yclid", "twclid", "ttclid", "li_fat_id", "wickedid",
                "oly_enc_id", "oly_anon_id", "vero_id", "vero_conv", "_ga", "_gl", "srsltid",
                "s_cid", "s_kwcid", "ocid", "icid", "cmpid", "spm",
            ],
            prefixes: ["utm_", "at_", "ns_", "pk_", "mtm_", "hsa_"]
        ),
        Rule(
            domains: ["linkedin.com", "lnkd.in"],
            names: [
                "trk", "trkinfo", "trkemail", "trackingid", "refid", "lipi", "licu", "lici", "rcm",
                "midtoken", "midsig", "eid", "otptoken", "originalsubdomain", "original_referer",
            ]
        ),
        Rule(domains: ["x.com", "twitter.com"], names: ["s", "t", "ref_src", "ref_url"]),
        Rule(domains: ["instagram.com"], names: ["igsh", "img_index"]),
        Rule(
            domains: ["facebook.com", "fb.com", "fb.me", "messenger.com"],
            names: ["mibextid", "rdid", "__cft__", "__tn__", "ref", "fref", "hc_ref", "sfnsn"]
        ),
        Rule(domains: ["threads.net", "threads.com"], names: ["xmt", "slof"]),
        Rule(domains: ["youtube.com", "youtu.be"], names: ["si", "pp", "feature"]),
        Rule(domains: ["spotify.com"], names: ["si", "nd", "dlsi"]),
        Rule(domains: ["tiktok.com"], names: ["is_from_webapp", "sender_device", "_r", "_t", "is_copy_url", "web_id"]),
        Rule(domains: ["reddit.com"], names: ["share_id", "rdt", "ref", "ref_source", "ref_campaign"]),
        Rule(domains: ["nytimes.com"], names: ["smid", "smtyp", "emc", "partner", "ugrp"]),
        Rule(domains: ["theguardian.com"], names: ["cmp"]),
        Rule(domains: ["washingtonpost.com"], names: ["itid", "wpisrc", "wpmk"]),
        Rule(domains: ["lemonde.fr", "lefigaro.fr", "liberation.fr"], names: ["xtor"]),
        Rule(domains: ["wsj.com", "barrons.com", "marketwatch.com"], names: ["mod", "reflink"]),
        Rule(domains: ["bloomberg.com"], names: ["srnd", "leadsource", "sref", "cmpid"]),
        Rule(domains: ["ft.com"], names: ["ftcamp", "segmentid", "sharetype"]),
        Rule(domains: ["telegraph.co.uk"], names: ["ito"]),
        Rule(domains: ["economist.com"], names: ["fsrc"]),
        Rule(domains: ["cnn.com"], names: ["iid"]),
        Rule(domains: ["amazon.com", "amazon.de", "amazon.co.uk", "amazon.se", "amazon.fr"],
             names: ["ref_", "pd_rd_w", "pd_rd_wg", "pd_rd_r", "pd_rd_i", "pf_rd_p", "pf_rd_r", "content-id", "linkcode", "tag"]),
    ]

    public init() {}

    public func clean(_ url: URL) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let items = components.queryItems else { return url }
        let applicable = rules(for: components.host ?? "")
        let kept = items.filter { item in !applicable.contains { $0.matches(item.name) } }
        guard kept.count != items.count else { return url }
        components.queryItems = kept.isEmpty ? nil : kept
        return components.url ?? url
    }

    private func rules(for host: String) -> [Rule] {
        Self.rules.filter { rule in
            rule.domains.isEmpty || rule.domains.contains { DomainMatch.host(host, isWithin: $0) }
        }
    }
}

extension URLCleaner.Rule {
    func matches(_ name: String) -> Bool {
        let name = name.lowercased()
        return names.contains(name) || prefixes.contains { name.hasPrefix($0) }
    }
}
