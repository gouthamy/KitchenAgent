//
//  ExpiryRemindersView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import SwiftData

struct ExpiryRemindersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FridgeItem.expiryDate) private var items: [FridgeItem]

    @State private var selectedFilter: ExpiryFilter = .expiringSoon
    @State private var enableDailyReminder = true
    @State private var reminderTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()

    enum ExpiryFilter: String, CaseIterable {
        case all = "All"
        case expiringSoon = "Expiring Soon"
        case expired = "Expired"
    }

    private var filteredItems: [FridgeItem] {
        switch selectedFilter {
        case .all:
            return items.filter { $0.expiryDate != nil }
        case .expiringSoon:
            return items.filter { $0.isExpiringSoon }
        case .expired:
            return items.filter { $0.isExpired }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filter Tabs
            Picker("Filter", selection: $selectedFilter) {
                ForEach(ExpiryFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // Items List
            if filteredItems.isEmpty {
                EmptyStateView(
                    icon: "checkmark.circle",
                    title: "All Good!",
                    message: selectedFilter == .expired
                        ? "No expired items"
                        : "No items expiring soon"
                )
            } else {
                List {
                    ForEach(filteredItems) { item in
                        NavigationLink {
                            ItemDetailView(item: item)
                        } label: {
                            ExpiryItemRow(item: item)
                        }
                    }
                }
                .listStyle(.plain)
            }

            // Daily Reminder Settings
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.orange)
                    Text("Daily Reminder")
                        .font(.headline)
                    Spacer()
                    Toggle("", isOn: $enableDailyReminder)
                        .onChange(of: enableDailyReminder) { oldValue, newValue in
                            if newValue {
                                NotificationService.shared.scheduleDailyReminder(at: reminderTime)
                            } else {
                                NotificationService.shared.cancelAllNotifications()
                            }
                        }
                }

                if enableDailyReminder {
                    HStack {
                        Text("You will get a reminder at")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .onChange(of: reminderTime) { oldValue, newValue in
                                NotificationService.shared.scheduleDailyReminder(at: newValue)
                            }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
        }
        .navigationTitle("Expiry Reminders")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExpiryItemRow: View {
    let item: FridgeItem

    var body: some View {
        HStack(spacing: 12) {
            // Image
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(item.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(item.emoji)
                            .font(.system(size: 35))
                    )
            }

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)

                if let days = item.daysUntilExpiry {
                    Text(days >= 0 ? "\(days) \(days == 1 ? "day" : "days") left" : "Expired")
                        .font(.subheadline)
                        .foregroundColor(days >= 0 ? (days <= 1 ? .orange : .green) : .red)
                }

                if let expiryDate = item.expiryDate {
                    Text("Exp: \(formatDate(expiryDate))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Status Indicator
            Circle()
                .fill(item.isExpired ? Color.red : Color.orange)
                .frame(width: 10, height: 10)
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        ExpiryRemindersView()
            .modelContainer(for: FridgeItem.self, inMemory: true)
    }
}
