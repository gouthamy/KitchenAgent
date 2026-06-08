//
//  NotificationService.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        return try await UNUserNotificationCenter.current().requestAuthorization(options: options)
    }

    func scheduleExpiryReminder(for item: FridgeItem) {
        guard let expiryDate = item.expiryDate else { return }

        let content = UNMutableNotificationContent()
        content.title = "Item Expiring Soon!"
        content.body = "\(item.name) will expire in \(item.daysUntilExpiry ?? 0) days"
        content.sound = .default

        // Schedule notification 1 day before expiry
        if let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: expiryDate) {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }

    func scheduleDailyReminder(at time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Check Your Fridge"
        content.body = "You have items expiring soon. Check your inventory!"
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: "daily-reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error)")
            }
        }
    }

    func cancelNotification(for itemId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [itemId.uuidString])
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
