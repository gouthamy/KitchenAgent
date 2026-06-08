//
//  EditItemView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI

struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: FridgeItem

    @State private var quantity: String
    @State private var expiryDate: Date
    @State private var location: StorageLocation
    @State private var notes: String

    init(item: FridgeItem) {
        self.item = item
        _quantity = State(initialValue: String(format: "%.0f", item.quantity))
        _expiryDate = State(initialValue: item.expiryDate ?? Date())
        _location = State(initialValue: item.location)
        _notes = State(initialValue: item.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(item.name)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        TextField("Quantity", text: $quantity)
                            .keyboardType(.decimalPad)
                            .foregroundColor(.primary)
                        Text(item.unit)
                            .foregroundColor(.secondary)
                    }
                }

                Section("Dates") {
                    DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: .date)
                }

                Section("Storage") {
                    Picker("Location", selection: $location) {
                        ForEach(StorageLocation.allCases, id: \.self) { location in
                            Label(location.rawValue, systemImage: location.icon)
                                .tag(location)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundColor(.primary)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveChanges() {
        item.quantity = Double(quantity) ?? item.quantity
        item.expiryDate = expiryDate
        item.location = location
        item.notes = notes.isEmpty ? nil : notes

        // Reschedule notification
        NotificationService.shared.cancelNotification(for: item.id)
        NotificationService.shared.scheduleExpiryReminder(for: item)

        dismiss()
    }
}
