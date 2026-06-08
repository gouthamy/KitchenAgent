//
//  InventoryView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import SwiftData

struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [FridgeItem]

    @State private var selectedLocation: StorageLocation? = nil
    @State private var searchText = ""
    @State private var showingAddItem = false

    private var filteredItems: [FridgeItem] {
        var result = items

        if let location = selectedLocation {
            result = result.filter { $0.location == location }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return result.sorted { $0.name < $1.name }
    }

    private var itemsByLocation: [(StorageLocation, Int)] {
        StorageLocation.allCases.map { location in
            let count = items.filter { $0.location == location }.count
            return (location, count)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar - Fixed at top
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search Item", text: $searchText)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)

                // Filter Pills - Fixed below search
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterPill(
                            title: "All (\(items.count))",
                            isSelected: selectedLocation == nil
                        ) {
                            selectedLocation = nil
                        }

                        ForEach(itemsByLocation, id: \.0) { location, count in
                            FilterPill(
                                title: "\(location.rawValue) (\(count))",
                                isSelected: selectedLocation == location,
                                icon: location.icon
                            ) {
                                selectedLocation = location
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)

                // Items Grid or Empty State - Scrollable content
                if filteredItems.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "tray",
                        title: "No Items",
                        message: "Add items to your inventory to get started"
                    )
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(filteredItems) { item in
                                NavigationLink {
                                    ItemDetailView(item: item)
                                } label: {
                                    InventoryItemCard(item: item)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contextMenu {
                                    Button(role: .destructive) {
                                        deleteItem(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        // Edit action would go here
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Inventory")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView()
            }
        }
    }

    private func deleteItem(_ item: FridgeItem) {
        withAnimation {
            NotificationService.shared.cancelNotification(for: item.id)
            modelContext.delete(item)
        }
    }
}

struct FilterPill: View {
    let title: String
    var isSelected: Bool
    var icon: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.green : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct InventoryItemCard: View {
    let item: FridgeItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                // Use pre-defined emoji for the item
                RoundedRectangle(cornerRadius: 12)
                    .fill(item.color.opacity(0.2))
                    .frame(height: 120)
                    .overlay(
                        Text(item.emoji)
                            .font(.system(size: 60))
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)

                Text("\(String(format: "%.0f", item.quantity)) \(item.unit)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let days = item.daysUntilExpiry {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(days <= 1 ? Color.red : (days <= 3 ? Color.orange : Color.green))
                            .frame(width: 6, height: 6)
                        Text("Exp: \(formatDate(item.expiryDate))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    InventoryView()
        .modelContainer(for: FridgeItem.self, inMemory: true)
}
