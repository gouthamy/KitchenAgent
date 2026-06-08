//
//  ShoppingListView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import SwiftData

struct ShoppingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ShoppingItem.addedDate, order: .reverse) private var items: [ShoppingItem]

    @State private var newItemName = ""
    @State private var newItemQuantity = ""
    @State private var showingAddSheet = false

    private var toBuyItems: [ShoppingItem] {
        items.filter { !$0.isPurchased }
    }

    private var recentlyBoughtItems: [ShoppingItem] {
        items.filter { $0.isPurchased }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Add Item Input
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)

                    TextField("Add item to list...", text: $newItemName)
                        .foregroundColor(.primary)
                        .onSubmit {
                            addItem()
                        }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()

                // To Buy Section
                if toBuyItems.isEmpty && recentlyBoughtItems.isEmpty {
                    EmptyStateView(
                        icon: "cart",
                        title: "Your list is empty",
                        message: "Add items to your shopping list"
                    )
                } else {
                    List {
                        if !toBuyItems.isEmpty {
                            Section(header: Text("To Buy")) {
                                ForEach(toBuyItems) { item in
                                    ShoppingItemRow(item: item) {
                                        togglePurchased(item)
                                    }
                                }
                                .onDelete { indexSet in
                                    deleteItems(at: indexSet, from: toBuyItems)
                                }
                            }
                        }

                        if !recentlyBoughtItems.isEmpty {
                            Section(header: Text("Recently Bought")) {
                                ForEach(recentlyBoughtItems) { item in
                                    ShoppingItemRow(item: item) {
                                        togglePurchased(item)
                                    }
                                }
                                .onDelete { indexSet in
                                    deleteItems(at: indexSet, from: recentlyBoughtItems)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Shopping List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            clearCompleted()
                        } label: {
                            Label("Clear Completed", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }

    private func addItem() {
        guard !newItemName.isEmpty else { return }

        let newItem = ShoppingItem(
            name: newItemName,
            quantity: newItemQuantity.isEmpty ? "1" : newItemQuantity
        )

        modelContext.insert(newItem)

        newItemName = ""
        newItemQuantity = ""
    }

    private func togglePurchased(_ item: ShoppingItem) {
        withAnimation {
            item.isPurchased.toggle()
        }
    }

    private func deleteItems(at offsets: IndexSet, from list: [ShoppingItem]) {
        for index in offsets {
            modelContext.delete(list[index])
        }
    }

    private func clearCompleted() {
        for item in recentlyBoughtItems {
            modelContext.delete(item)
        }
    }
}

struct ShoppingItemRow: View {
    let item: ShoppingItem
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Button {
                onToggle()
            } label: {
                Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isPurchased ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                    .strikethrough(item.isPurchased)
                    .foregroundColor(item.isPurchased ? .secondary : .primary)

                Text(item.quantity)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ShoppingListView()
        .modelContainer(for: ShoppingItem.self, inMemory: true)
}
