import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var notificationManager: NotificationManager

    var body: some View {
        NavigationStack {
            List {
                Section("Notifications") {
                    if notificationManager.isAuthorized {
                        Label("Notifications Enabled", systemImage: "bell.badge.fill")
                            .foregroundStyle(.green)

                        LabeledContent("Pending Reminders", value: "\(notificationManager.pendingCount)")
                    } else {
                        Button {
                            Task {
                                await notificationManager.requestAuthorization()
                            }
                        } label: {
                            Label("Enable Notifications", systemImage: "bell.slash")
                        }
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                }
            }
            .navigationTitle("Settings")
            .task {
                await notificationManager.checkAuthorizationStatus()
                await notificationManager.refreshPendingCount()
            }
        }
    }
}

#if DEBUG
#Preview {
    SettingsView()
        .environmentObject(NotificationManager.shared)
}
#endif
