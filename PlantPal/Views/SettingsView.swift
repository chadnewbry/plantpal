import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var proManager: PlantPalProManager
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if proManager.isPro {
                        HStack {
                            Label("PlantPal Pro", systemImage: "leaf.circle.fill")
                                .foregroundStyle(.green)
                            Spacer()
                            Text("Active")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                                .fontWeight(.medium)
                        }
                    } else {
                        Button {
                            showPaywall = true
                        } label: {
                            HStack {
                                Label("Upgrade to Pro", systemImage: "leaf.circle.fill")
                                Spacer()
                                Text("$6.99")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }

                        Button("Restore Purchase") {
                            Task {
                                try? await proManager.restorePurchases()
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("PlantPal Pro")
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
        .environmentObject(PlantPalProManager.shared)
}
#endif
