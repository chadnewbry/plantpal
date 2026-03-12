import SwiftUI

@main
struct PlantPalApp: App {
    @State private var useDummyData = CommandLine.arguments.contains("-dummy-data")
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var syncManager = CloudKitSyncManager.shared

    private let notificationDelegate = NotificationDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            ContentView(useDummyData: useDummyData)
                .environmentObject(notificationManager)
                .environmentObject(syncManager)
                .task {
                    await notificationManager.checkAuthorizationStatus()
                    syncManager.startMonitoring(container: PersistenceController.shared.container)
                }
        }
    }
}
