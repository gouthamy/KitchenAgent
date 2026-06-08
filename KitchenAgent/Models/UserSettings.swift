//
//  UserSettings.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import Foundation
import SwiftData

@Model
final class UserSettings {
    var id: UUID
    var userName: String
    var userEmail: String
    var profileImageData: Data?
    var reminderTime: Date
    var enableNotifications: Bool
    var preferredUnit: String // "Gram (g)" or "Kilogram (kg)"
    var enableFamilySharing: Bool

    init(id: UUID = UUID(), userName: String = "Priya", userEmail: String = "priya@example.com", profileImageData: Data? = nil, reminderTime: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date(), enableNotifications: Bool = true, preferredUnit: String = "Gram (g)", enableFamilySharing: Bool = false) {
        self.id = id
        self.userName = userName
        self.userEmail = userEmail
        self.profileImageData = profileImageData
        self.reminderTime = reminderTime
        self.enableNotifications = enableNotifications
        self.preferredUnit = preferredUnit
        self.enableFamilySharing = enableFamilySharing
    }
}
