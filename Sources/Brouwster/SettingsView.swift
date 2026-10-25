import BrouwsterCore
import SwiftUI

struct SettingsView: View {
    @Bindable var model: AppModel

    var body: some View {
        TabView {
            RulesTab(model: model).tabItem { Label("Rules", systemImage: "arrow.triangle.branch") }
            BrowsersTab(model: model).tabItem { Label("Browsers", systemImage: "globe") }
        }
        .padding()
        .frame(minWidth: 640, minHeight: 460)
    }
}

/// Picker over every installed browser and profile, keeping an unknown current value visible.
struct TargetPicker: View {
    let title: String
    @Binding var selection: BrowserTarget
    let model: AppModel

    var body: some View {
        Picker(title, selection: $selection) {
            if !model.targets.contains(selection) {
                Text(model.label(for: selection)).tag(selection)
            }
            ForEach(model.targets, id: \.self) { Text(model.label(for: $0)).tag($0) }
        }
    }
}

private struct RulesTab: View {
    @Bindable var model: AppModel
    @State private var testURL = ""

    var body: some View {
        Form {
            Section {
                HStack {
                    Text(model.isDefaultBrowser ? "Brouwster is the default browser." : "Brouwster is not the default browser.")
                        .foregroundStyle(model.isDefaultBrowser ? .secondary : .primary)
                    Spacer()
                    if !model.isDefaultBrowser {
                        Button("Make Default Browser") { model.makeDefaultBrowser() }
                    }
                }
                Picker("Open other links in", selection: $model.config.defaultTarget) {
                    Text("Safari (built-in fallback)").tag(BrowserTarget?.none)
                    if let current = model.config.defaultTarget, !model.targets.contains(current) {
                        Text(model.label(for: current)).tag(BrowserTarget?.some(current))
                    }
                    ForEach(model.targets, id: \.self) { Text(model.label(for: $0)).tag(BrowserTarget?.some($0)) }
                }
            }

            Section {
                ForEach($model.config.rules) { $rule in
                    HStack {
                        TextField("Domain", text: $rule.domain, prompt: Text("linkedin.com"))
                            .frame(maxWidth: 220)
                        TargetPicker(title: "Opens in", selection: $rule.target, model: model)
                            .labelsHidden()
                        Button {
                            model.removeRule(rule.id)
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        .buttonStyle(.borderless)
                        .help("Remove rule")
                    }
                }
                Button("Add Rule", systemImage: "plus") { model.addRule() }
            } header: {
                Text("Domain rules")
            } footer: {
                Text("A domain also matches its subdomains: linkedin.com covers www.linkedin.com and fi.linkedin.com. The most specific rule wins.")
                    .foregroundStyle(.secondary)
            }

            Section("Try a link") {
                TextField("URL", text: $testURL, prompt: Text("https://www.linkedin.com/feed/?trk=abc"))
                if let preview = model.preview(testURL) {
                    LabeledContent("Cleaned", value: preview.cleaned.absoluteString)
                        .textSelection(.enabled)
                    LabeledContent("Opens in", value: preview.target.map(model.label(for:)) ?? "Safari (fallback)")
                }
            }
        }
        .formStyle(.grouped)
    }
}

private struct BrowsersTab: View {
    let model: AppModel

    var body: some View {
        VStack(alignment: .leading) {
            List(model.browsers) { browser in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(nsImage: browser.icon).resizable().frame(width: 24, height: 24)
                        Text(browser.name).font(.headline)
                        Text(browser.bundleIdentifier).foregroundStyle(.secondary).font(.caption)
                    }
                    ForEach(browser.profiles) { profile in
                        HStack {
                            Image(systemName: "person.crop.circle").foregroundStyle(.secondary)
                            Text(profile.name)
                            if let email = profile.email { Text(email).foregroundStyle(.secondary) }
                            Spacer()
                            if profile.directory != profile.name {
                                Text(profile.directory).foregroundStyle(.tertiary).font(.caption)
                            }
                        }
                        .padding(.leading, 32)
                    }
                }
                .padding(.vertical, 2)
            }
            HStack {
                Text("\(model.browsers.count) browsers, \(model.browsers.map(\.profiles.count).reduce(0, +)) profiles")
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Rescan Browsers and Profiles", systemImage: "arrow.clockwise") { model.rescan() }
            }
        }
    }
}
