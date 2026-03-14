import SwiftUI

struct SettingsView: View {
    private let feedbackEmail = "chad.newbry@gmail.com"
    private let appName = "PlantPal"

    var body: some View {
        NavigationStack {
            List {
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
        }
    }
}

#if DEBUG
#Preview {
    SettingsView()
}
#endif
