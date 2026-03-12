import CoreData
import CloudKit
import Combine
import os.log

/// Manages CloudKit sync status and error handling for PlantPal.
/// Uses NSPersistentCloudKitContainer's automatic sync via the user's
/// private CloudKit database — all data stays private to the user's iCloud account.
@MainActor
final class CloudKitSyncManager: ObservableObject {
    static let shared = CloudKitSyncManager()

    private static let logger = Logger(subsystem: "com.chadnewbry.plantpal", category: "CloudKitSync")

    enum SyncStatus: Equatable {
        case idle
        case syncing
        case succeeded
        case failed(String)
        case accountUnavailable

        var displayText: String {
            switch self {
            case .idle: return "Waiting to sync"
            case .syncing: return "Syncing…"
            case .succeeded: return "Up to date"
            case .failed(let message): return "Sync error: \(message)"
            case .accountUnavailable: return "iCloud account unavailable"
            }
        }

        var systemImage: String {
            switch self {
            case .idle: return "cloud"
            case .syncing: return "arrow.triangle.2.circlepath.icloud"
            case .succeeded: return "checkmark.icloud"
            case .failed: return "exclamationmark.icloud"
            case .accountUnavailable: return "icloud.slash"
            }
        }
    }

    @Published private(set) var syncStatus: SyncStatus = .idle
    @Published private(set) var lastSyncDate: Date?

    private var eventSubscription: AnyCancellable?

    private init() {}

    /// Start observing sync events from the persistent container.
    func startMonitoring(container: NSPersistentCloudKitContainer) {
        eventSubscription = NotificationCenter.default
            .publisher(for: NSPersistentCloudKitContainer.eventChangedNotification, object: container)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self,
                      let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else {
                    return
                }
                self.handleEvent(event)
            }

        Task {
            await checkAccountStatus()
        }
    }

    func checkAccountStatus() async {
        do {
            let status = try await CKContainer.default().accountStatus()
            switch status {
            case .available:
                if syncStatus == .accountUnavailable {
                    syncStatus = .idle
                }
            case .noAccount, .restricted, .couldNotDetermine, .temporarilyUnavailable:
                syncStatus = .accountUnavailable
            @unknown default:
                break
            }
        } catch {
            Self.logger.error("Failed to check iCloud account status: \(error.localizedDescription)")
        }
    }

    private func handleEvent(_ event: NSPersistentCloudKitContainer.Event) {
        if event.endDate == nil {
            syncStatus = .syncing
        } else if event.succeeded {
            syncStatus = .succeeded
            lastSyncDate = event.endDate
        } else if let error = event.error {
            Self.logger.error("CloudKit sync error: \(error.localizedDescription)")
            syncStatus = .failed(error.localizedDescription)
        }
    }
}
