import Foundation
import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    /// Called when a notification is delivered while the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }

    /// Called when the user interacts with a notification (tap or action button).
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        guard let plantIdString = userInfo["plantId"] as? String else { return }

        switch response.actionIdentifier {
        case NotificationManager.actionWatered:
            // Post notification so the app can mark the plant as watered
            await MainActor.run {
                NotificationCenter.default.post(
                    name: .plantWateredFromNotification,
                    object: nil,
                    userInfo: ["plantId": plantIdString]
                )
            }

        case NotificationManager.actionSnooze:
            // Reschedule for tomorrow at 9 AM
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
            var components = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
            components.hour = 9
            components.minute = 0
            guard let snoozeDate = Calendar.current.date(from: components) else { return }

            let content = response.notification.request.content.mutableCopy() as! UNMutableNotificationContent
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: snoozeDate),
                repeats: false
            )
            let request = UNNotificationRequest(
                identifier: response.notification.request.identifier,
                content: content,
                trigger: trigger
            )
            try? await UNUserNotificationCenter.current().add(request)

        default:
            // Default tap — post so the app can navigate to the plant
            await MainActor.run {
                NotificationCenter.default.post(
                    name: .plantSelectedFromNotification,
                    object: nil,
                    userInfo: ["plantId": plantIdString]
                )
            }
        }
    }
}

extension Notification.Name {
    static let plantWateredFromNotification = Notification.Name("plantWateredFromNotification")
    static let plantSelectedFromNotification = Notification.Name("plantSelectedFromNotification")
}
