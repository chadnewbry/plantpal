import SwiftUI

struct SettingsView: View {
    private let feedbackEmail = "chad.newbry@gmail.com"
    private let appName = "PlantPal"
    @ObservedObject private var proManager = PlantPalProManager.shared
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            List {
                if !proManager.isPro {
                    Section {
                        Button {
                            showPaywall = true
                        } label: {
                            Label("Upgrade to Pro", systemImage: "leaf.circle.fill")
                                .foregroundStyle(.green)
                        }
                        .accessibilityIdentifier("upgradeToProButton")
                    }
                }

                Section("Feedback") {
                    Button {
                        let subject = "Feedback: \(appName)"
                            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        if let url = URL(string: "mailto:\(feedbackEmail)?subject=\(subject)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Feedback / Product Suggestions", systemImage: "envelope")
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                ProPaywallView()
            }
        }
    }
}

#if DEBUG
#Preview {
    SettingsView()
}
#endif
