import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var syncManager: CloudKitSyncManager
    @StateObject private var notificationManager = NotificationManager.shared
    @AppStorage("reminderHour") private var reminderHour: Int = 9
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0
    @AppStorage("wateringRemindersEnabled") private var wateringRemindersEnabled = true
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    @State private var showingDeleteConfirmation = false
    @State private var notificationTime = Date()

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        NavigationStack {
            List {
                iCloudSyncSection
                notificationsSection
                dataManagementSection
                privacySection
                aboutSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showingTermsOfService) {
                TermsOfServiceView()
            }
            .confirmationDialog(
                "Delete All Plant Data",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete All Data", role: .destructive) {
                    deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently remove all your plants and care history. This action cannot be undone.")
            }
            .onAppear {
                Task {
                    await notificationManager.checkAuthorizationStatus()
                    await notificationManager.refreshPendingCount()
                }
                notificationTime = makeTime(hour: reminderHour, minute: reminderMinute)
            }
        }
    }

    // MARK: - Sections

    private var iCloudSyncSection: some View {
        Section {
            HStack {
                Image(systemName: syncManager.syncStatus.systemImage)
                    .foregroundStyle(syncStatusColor)
                Text(syncManager.syncStatus.displayText)
            }
            .accessibilityIdentifier("syncStatus")

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
        } header: {
            Text("iCloud Sync")
        }
    }

    private var notificationsSection: some View {
        Section {
            Toggle("Watering Reminders", isOn: $wateringRemindersEnabled)
                .accessibilityIdentifier("wateringRemindersToggle")
                .onChange(of: wateringRemindersEnabled) { _, enabled in
                    if enabled {
                        Task { _ = await notificationManager.requestAuthorization() }
                    }
                }

            if wateringRemindersEnabled {
                if !notificationManager.isAuthorized {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Enable in System Settings", systemImage: "bell.badge")
                            .foregroundStyle(.orange)
                    }
                } else {
                    DatePicker(
                        "Reminder Time",
                        selection: $notificationTime,
                        displayedComponents: .hourAndMinute
                    )
                    .accessibilityIdentifier("reminderTimePicker")
                    .onChange(of: notificationTime) { _, newValue in
                        let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                        reminderHour = components.hour ?? 9
                        reminderMinute = components.minute ?? 0
                    }

                    LabeledContent("Pending Reminders") {
                        Text("\(notificationManager.pendingCount)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text("Notifications")
        } footer: {
            if wateringRemindersEnabled {
                Text("You'll receive a reminder when each plant is due for watering.")
            }
        }
    }

    private var dataManagementSection: some View {
        Section {
            Button {
                exportPlantData()
            } label: {
                Label("Export Plant Data", systemImage: "square.and.arrow.up")
            }
            .accessibilityIdentifier("exportDataButton")

            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                Label("Delete All Data", systemImage: "trash")
            }
            .accessibilityIdentifier("deleteAllDataButton")
        } header: {
            Text("Data Management")
        }
    }

    private var privacySection: some View {
        Section {
            Button {
                showingPrivacyPolicy = true
            } label: {
                HStack {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .foregroundStyle(.primary)
            .accessibilityIdentifier("privacyPolicyButton")

            Button {
                showingTermsOfService = true
            } label: {
                HStack {
                    Label("Terms of Service", systemImage: "doc.text")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .foregroundStyle(.primary)
            .accessibilityIdentifier("termsOfServiceButton")

            Link(destination: URL(string: "mailto:support@chadnewbry.com")!) {
                Label("Contact Support", systemImage: "envelope")
            }
            .accessibilityIdentifier("contactSupportButton")
        } header: {
            Text("Privacy & Support")
        }
    }

    private var aboutSection: some View {
        Section {
            LabeledContent("Version", value: appVersion)
                .accessibilityIdentifier("appVersion")
            LabeledContent("Build", value: buildNumber)
            HStack {
                Text("Made with")
                Image(systemName: "leaf.fill")
                    .foregroundStyle(.green)
                Text("by Chad Newbry")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
        } header: {
            Text("About")
        }
    }

    // MARK: - Helpers

    private var syncStatusColor: Color {
        switch syncManager.syncStatus {
        case .idle: return .secondary
        case .syncing: return .blue
        case .succeeded: return .green
        case .failed: return .red
        case .accountUnavailable: return .orange
        }
    }

    private func makeTime(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? .now
    }

    private func exportPlantData() {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest = CDPlant.fetchRequest()
        guard let plants = try? context.fetch(fetchRequest), !plants.isEmpty else { return }

        var csv = "Name,Species,Watering Interval (days),Last Watered,Date Added,Notes\n"
        let formatter = ISO8601DateFormatter()
        for plant in plants {
            let name = plant.name ?? ""
            let species = plant.species ?? ""
            let interval = plant.wateringInterval
            let lastWatered = plant.lastWatered.map { formatter.string(from: $0) } ?? ""
            let dateAdded = plant.dateAdded.map { formatter.string(from: $0) } ?? ""
            let notes = (plant.notes ?? "").replacingOccurrences(of: "\"", with: "\"\"")
            csv += "\"\(name)\",\"\(species)\",\(interval),\(lastWatered),\(dateAdded),\"\(notes)\"\n"
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("PlantPal-Export.csv")
        try? csv.write(to: tempURL, atomically: true, encoding: .utf8)

        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let rootVC = window.rootViewController else { return }

        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
        rootVC.present(activityVC, animated: true)
    }

    private func deleteAllData() {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest = CDPlant.fetchRequest()
        if let plants = try? context.fetch(fetchRequest) {
            for plant in plants {
                context.delete(plant)
            }
            try? context.save()
        }
        Task {
            await notificationManager.cancelAllReminders()
        }
    }
}

// MARK: - Privacy Policy View

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        sectionBlock(
                            title: "Overview",
                            body: "PlantPal is designed with your privacy in mind. We do not collect, transmit, or sell your personal data. Everything stays on your device and your personal iCloud account."
                        )

                        sectionBlock(
                            title: "Data We Collect",
                            body: """
                            • Plant names, species, photos, and notes you enter
                            • Care schedules (watering, fertilizing, repotting, light tracking)
                            • Care event history and calendar data
                            • App preferences and settings

                            All data is stored locally using Core Data. We do not collect analytics, usage data, or personal information.
                            """
                        )

                        sectionBlock(
                            title: "iCloud Sync",
                            body: "If you have iCloud enabled, your plant data syncs across your devices using Apple's CloudKit. This data is stored in your private iCloud database, encrypted in transit and at rest by Apple, and is not accessible to us or any third party."
                        )

                        sectionBlock(
                            title: "AI Plant Health",
                            body: "PlantPal's AI plant health analysis runs entirely on your device using Apple's on-device machine learning frameworks. No photos or health data are sent to external servers."
                        )
                    }

                    Group {
                        sectionBlock(
                            title: "Notifications",
                            body: "PlantPal uses local notifications for care reminders. These are generated entirely on your device — no data is sent externally."
                        )

                        sectionBlock(
                            title: "Apple Watch & Widgets",
                            body: "The Apple Watch app and Home Screen widgets display your plant care data locally. No data is transmitted externally."
                        )

                        sectionBlock(
                            title: "Siri Integration",
                            body: "PlantPal provides data to Siri locally through App Intents. Voice interactions are handled by Apple according to Apple's privacy policy."
                        )

                        sectionBlock(
                            title: "Third-Party Services",
                            body: "PlantPal does not use any third-party analytics, advertising, or tracking services."
                        )

                        sectionBlock(
                            title: "Data Deletion",
                            body: "You can delete all your data from Settings > Data Management > Delete All Data. To remove iCloud data, manage it in your iCloud storage settings."
                        )

                        sectionBlock(
                            title: "Children's Privacy",
                            body: "PlantPal does not knowingly collect any personal information from anyone, including children under 13."
                        )

                        sectionBlock(
                            title: "Contact",
                            body: "Questions? Contact us at support@chadnewbry.com."
                        )
                    }

                    Text("Last updated: March 2026")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
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
    SettingsView()
        .environmentObject(CloudKitSyncManager.shared)
}

#Preview("Privacy Policy") {
    PrivacyPolicyView()
}
#endif
