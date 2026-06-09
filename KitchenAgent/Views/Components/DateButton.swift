//
//  DateButton.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI

struct DateButton: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void

    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.xs) {
                Text(dayName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .secondary)
                Text(dayNumber)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 50)
            .padding(.vertical, Theme.Spacing.md)
            .background(isSelected ? Theme.Colors.primary : Theme.Colors.background)
            .cornerRadius(Theme.CornerRadius.md)
        }
    }
}
