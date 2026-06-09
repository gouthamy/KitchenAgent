//
//  DateExtensions.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import Foundation

extension Date {
    /// Check if the date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Check if the date is tomorrow
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    /// Calculate days until a specific date
    func daysUntil(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: self), to: calendar.startOfDay(for: date))
        return components.day ?? 0
    }

    /// Calculate days from a specific date to this date
    func daysFrom(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: self))
        return components.day ?? 0
    }

    /// Format date with a specific style
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// Format date as "Today", "Tomorrow", or relative date
    var relativeFormatted: String {
        if isToday {
            return "Today"
        } else if isTomorrow {
            return "Tomorrow"
        } else {
            let days = Date.now.daysUntil(self)
            if days > 0 && days <= 7 {
                return "in \(days) \(days == 1 ? "day" : "days")"
            } else if days < 0 && days >= -7 {
                return "\(-days) \(days == -1 ? "day" : "days") ago"
            } else {
                return formatted(style: .short)
            }
        }
    }
}
