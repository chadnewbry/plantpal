import SwiftUI

struct SettingsView: View {
    private let config = AppConfig.shared

    var body: some View {
        NavigationStack {
            List {
                Section("Links") {
                    if let url = URL(string: config.urls.website) {
                        Link("Website", destination: url)
                    }
                    if let url = URL(string: config.urls.privacyPolicy) {
                        Link("Privacy Policy", destination: url)
                    }
                    if let url = URL(string: config.urls.termsOfService) {
                        Link("Terms of Service", destination: url)
                    }
                    if let url = URL(string: config.urls.support) {
                        Link("Support", destination: url)
                    }
                }

                Section("Help") {
                    Button {
                        let email = config.review?.contactEmail ?? "chad.newbry@gmail.com"
                        if let url = URL(string: "mailto:\(email)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Contact Support", systemImage: "envelope")
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    if let appName = config.appName {
                        LabeledContent("App", value: appName)
                    }
                    LabeledContent("Copyright", value: config.copyright)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#if DEBUG
#Preview {
    SettingsView()
}
#endif
