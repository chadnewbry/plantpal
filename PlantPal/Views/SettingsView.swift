import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var syncManager: CloudKitSyncManager

    var body: some View {
        NavigationStack {
            List {
                Section("iCloud Sync") {
                    HStack {
                        Image(systemName: syncManager.syncStatus.systemImage)
                            .foregroundStyle(syncStatusColor)
                        Text(syncManager.syncStatus.displayText)
                    }

                    if let lastSync = syncManager.lastSyncDate {
                        LabeledContent("Last synced") {
                            Text(lastSync, style: .relative)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if case .accountUnavailable = syncManager.syncStatus {
                        Text("Sign in to iCloud in Settings to sync your plants across devices.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var syncStatusColor: Color {
        switch syncManager.syncStatus {
        case .idle: return .secondary
        case .syncing: return .blue
        case .succeeded: return .green
        case .failed: return .red
        case .accountUnavailable: return .orange
        }
    }
}

#if DEBUG
#Preview {
    SettingsView()
        .environmentObject(CloudKitSyncManager.shared)
}
#endif
