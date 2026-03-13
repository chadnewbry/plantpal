import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false
    @Published var pendingCount = 0

    private let center = UNUserNotificationCenter.current()
    private let categoryIdentifier = "WATERING_REMINDER"

    // Action identifiers
    static let actionWatered = "MARK_WATERED"
    static let actionSnooze = "SNOOZE_1_DAY"

    private init() {
        setupCategory()
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            return granted
        } catch {
            print("NotificationManager: authorization error — \(error.localizedDescription)")
            return false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    // MARK: - Category & Actions

    private func setupCategory() {
        let wateredAction = UNNotificationAction(
            identifier: Self.actionWatered,
            title: "💧 Watered",
            options: []
        )
        let snoozeAction = UNNotificationAction(
            identifier: Self.actionSnooze,
            title: "⏰ Remind Tomorrow",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: categoryIdentifier,
            actions: [wateredAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([category])
    }

    // MARK: - Schedule

    func scheduleWateringReminder(for plant: Plant, at date: Date) async {
        guard isAuthorized else {
            let granted = await requestAuthorization()
            guard granted else { return }
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Time to water \(plant.name)! 🌱"
        content.body = "\(plant.name) (\(plant.species)) is due for watering."
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier
        content.userInfo = [
            "plantId": plant.id.uuidString,
            "plantName": plant.name
        ]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: notificationId(for: plant),
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            await refreshPendingCount()
        } catch {
            print("NotificationManager: failed to schedule — \(error.localizedDescription)")
        }
    }

    func scheduleNextReminder(for plant: Plant, hour: Int = 9, minute: Int = 0) async {
        guard let nextDate = Calendar.current.date(
            byAdding: .day,
            value: plant.wateringInterval,
            to: plant.lastWatered
        ) else { return }

        var components = Calendar.current.dateComponents([.year, .month, .day], from: nextDate)
        components.hour = hour
        components.minute = minute
        guard let reminderDate = Calendar.current.date(from: components) else { return }

        let finalDate: Date
        if reminderDate < .now {
            finalDate = Date().addingTimeInterval(5)
        } else {
            finalDate = reminderDate
        }

        await scheduleWateringReminder(for: plant, at: finalDate)
    }

    // MARK: - Cancel

    func cancelReminder(for plant: Plant) async {
        center.removePendingNotificationRequests(withIdentifiers: [notificationId(for: plant)])
        await refreshPendingCount()
    }

    func cancelAllReminders() async {
        center.removeAllPendingNotificationRequests()
        await refreshPendingCount()
    }

    // MARK: - Reschedule All

    func rescheduleAll(for plants: [Plant], hour: Int = 9, minute: Int = 0) async {
        await cancelAllReminders()
        for plant in plants {
            await scheduleNextReminder(for: plant, hour: hour, minute: minute)
        }
    }

    // MARK: - Query

    func pendingReminders() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }

    func refreshPendingCount() async {
        let pending = await center.pendingNotificationRequests()
        pendingCount = pending.count
    }

    // MARK: - Helpers

    private func notificationId(for plant: Plant) -> String {
        "watering-\(plant.id.uuidString)"
    }
}
