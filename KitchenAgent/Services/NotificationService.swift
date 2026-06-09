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

    // MARK: - Meal Reminders

    /// Schedule a cooking reminder for a meal
    /// - Parameters:
    ///   - meal: The planned meal to schedule reminder for
    ///   - prepTime: Minutes before meal time to send reminder
    func scheduleMealReminder(for meal: PlannedMeal, prepTime: Int? = nil) throws {
        // Use provided prep time or fall back to meal's prep time
        let reminderPrepTime = prepTime ?? meal.prepTime

        // Calculate the time to send notification (prep time before meal)
        guard let notificationDate = Calendar.current.date(
            byAdding: .minute,
            value: -reminderPrepTime,
            to: meal.date
        ) else {
            throw NotificationError.invalidDate
        }

        // Don't schedule if notification time is in the past
        guard notificationDate > Date() else {
            throw NotificationError.pastDate
        }

        let content = UNMutableNotificationContent()
        content.title = "Time to Cook!"
        content.body = "Time to start cooking \(meal.recipeName). Takes approximately \(meal.cookingTime) minutes."
        content.sound = .default
        content.categoryIdentifier = "MEAL_REMINDER"

        // Add meal details to userInfo
        content.userInfo = [
            "mealId": meal.id.uuidString,
            "mealName": meal.recipeName,
            "mealType": meal.mealType.rawValue,
            "cookingTime": meal.cookingTime
        ]

        // Create trigger
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: notificationDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        // Create request
        let identifier = "meal-reminder-\(meal.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling meal reminder: \(error.localizedDescription)")
            } else {
                print("Successfully scheduled meal reminder for \(meal.recipeName) at \(notificationDate)")
            }
        }
    }

    /// Schedule reminders for multiple meals
    /// - Parameters:
    ///   - meals: Array of planned meals
    ///   - prepTime: Optional override for prep time (uses each meal's prep time if nil)
    func scheduleMealReminders(for meals: [PlannedMeal], prepTime: Int? = nil) {
        for meal in meals {
            do {
                try scheduleMealReminder(for: meal, prepTime: prepTime)
            } catch {
                print("Failed to schedule reminder for \(meal.recipeName): \(error.localizedDescription)")
            }
        }
    }

    /// Cancel a specific meal reminder
    /// - Parameter mealId: The UUID of the meal to cancel reminder for
    func cancelMealReminder(for mealId: UUID) {
        let identifier = "meal-reminder-\(mealId.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    /// Cancel all meal reminders
    func cancelAllMealReminders() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let mealReminderIds = requests
                .filter { $0.identifier.hasPrefix("meal-reminder-") }
                .map { $0.identifier }

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: mealReminderIds)
            print("Cancelled \(mealReminderIds.count) meal reminders")
        }
    }

    /// Get all pending meal reminders
    func getPendingMealReminders(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let mealReminders = requests.filter { $0.identifier.hasPrefix("meal-reminder-") }
            completion(mealReminders)
        }
    }

    /// Check if a meal has a scheduled reminder
    /// - Parameter mealId: The UUID of the meal
    /// - Returns: True if reminder is scheduled, false otherwise
    func hasMealReminder(for mealId: UUID, completion: @escaping (Bool) -> Void) {
        let identifier = "meal-reminder-\(mealId.uuidString)"
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let hasReminder = requests.contains { $0.identifier == identifier }
            completion(hasReminder)
        }
    }
}

// MARK: - Notification Errors

enum NotificationError: LocalizedError {
    case invalidDate
    case pastDate
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidDate:
            return "Could not calculate notification date"
        case .pastDate:
            return "Cannot schedule notification for past date"
        case .unauthorized:
            return "Notification permission not granted"
        }
    }
}
