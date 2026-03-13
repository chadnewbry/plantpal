import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    sectionBlock(
                        title: "Use of the App",
                        body: "PlantPal is a plant care management app for personal, non-commercial use. You agree not to reverse engineer, decompile, or use the App for any unlawful purpose."
                    )

                    sectionBlock(
                        title: "Purchases",
                        body: "PlantPal offers a one-time purchase to unlock premium features. All purchases are processed through Apple's App Store and are subject to Apple's Terms and Conditions. Refund requests should be directed to Apple."
                    )

                    sectionBlock(
                        title: "User Data",
                        body: "All plant data is stored locally on your device and optionally synced via your personal iCloud account. You are responsible for maintaining backups of your data. See our Privacy Policy for full details."
                    )

                    sectionBlock(
                        title: "AI Plant Health Features",
                        body: "AI-powered plant health analysis runs on-device and is provided for informational purposes only. We do not guarantee the accuracy of AI-generated assessments and are not responsible for actions taken based on them."
                    )

                    sectionBlock(
                        title: "Intellectual Property",
                        body: "PlantPal and all its content, features, and functionality are owned by Chad Newbry LLC and are protected by copyright, trademark, and other intellectual property laws."
                    )

                    sectionBlock(
                        title: "Disclaimer of Warranties",
                        body: "PlantPal is provided \"AS IS\" and \"AS AVAILABLE\" without warranties of any kind, either express or implied. Plant care suggestions are informational only. We are not responsible for any harm to your plants resulting from following the App's recommendations."
                    )

                    sectionBlock(
                        title: "Limitation of Liability",
                        body: "To the maximum extent permitted by applicable law, Chad Newbry LLC shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits, data, or goodwill, arising out of or in connection with your use of PlantPal."
                    )

                    sectionBlock(
                        title: "Governing Law",
                        body: "These Terms shall be governed by and construed in accordance with the laws of the State of California, United States."
                    )

                    sectionBlock(
                        title: "Contact Us",
                        body: "If you have questions about these Terms of Service, please contact us at support@chadnewbry.com."
                    )

                    Text("Last updated: March 2026")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding()
            }
            .navigationTitle("Terms of Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func sectionBlock(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#if DEBUG
#Preview {
    TermsOfServiceView()
}
#endif
