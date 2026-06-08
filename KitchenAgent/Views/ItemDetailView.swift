//
//  ItemDetailView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import SwiftData

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: FridgeItem

    @State private var showingDeleteAlert = false
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Image
                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(item.color.opacity(0.2))
                        .frame(height: 250)
                        .overlay(
                            Text(item.emoji)
                                .font(.system(size: 100))
                        )
                }

                VStack(spacing: 16) {
                    // Name & Category
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.title)
                                .fontWeight(.bold)
                            Text(item.category.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }

                    // Stats
                    HStack(spacing: 20) {
                        StatCard(
                            icon: "scalemass",
                            title: "Quantity",
                            value: "\(String(format: "%.0f", item.quantity)) \(item.unit)"
                        )

                        StatCard(
                            icon: item.location.icon,
                            title: "Location",
                            value: item.location.rawValue
                        )
                    }

                    // Dates
                    VStack(spacing: 12) {
                        DateRow(
                            icon: "cart",
                            title: "Purchase Date",
                            date: item.purchaseDate
                        )

                        if let expiryDate = item.expiryDate {
                            DateRow(
                                icon: "calendar.badge.exclamationmark",
                                title: "Expiry Date",
                                date: expiryDate,
                                isWarning: item.isExpiringSoon
                            )

                            if let days = item.daysUntilExpiry {
                                HStack {
                                    Text(days >= 0 ? "\(days) days left" : "Expired \(-days) days ago")
                                        .font(.headline)
                                        .foregroundColor(days >= 0 ? (days <= 3 ? .orange : .green) : .red)
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    (days >= 0 ? (days <= 3 ? Color.orange : Color.green) : Color.red)
                                        .opacity(0.1)
                                )
                                .cornerRadius(12)
                            }
                        }
                    }

                    // Notes
                    if let notes = item.notes {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                            Text(notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }

                    // Action Buttons
                    VStack(spacing: 12) {
                        Button {
                            isEditing = true
                        } label: {
                            Label("Edit Item", systemImage: "pencil")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete Item", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Item", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteItem()
            }
        } message: {
            Text("Are you sure you want to delete \(item.name)?")
        }
        .sheet(isPresented: $isEditing) {
            EditItemView(item: item)
        }
    }

    private func deleteItem() {
        NotificationService.shared.cancelNotification(for: item.id)
        modelContext.delete(item)
        dismiss()
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct DateRow: View {
    let icon: String
    let title: String
    let date: Date
    var isWarning: Bool = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isWarning ? .orange : .green)
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(formatDate(date))
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        ItemDetailView(item: FridgeItem(
            name: "Tomato",
            quantity: 500,
            unit: "g",
            purchaseDate: Date(),
            expiryDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
            location: .fridge,
            notes: "Fresh tomatoes from market",
            category: .vegetable
        ))
    }
    .modelContainer(for: FridgeItem.self, inMemory: true)
}
