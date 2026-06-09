//
//  MealPlanShoppingView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import SwiftData

struct MealPlanShoppingView: View {
    let mealPlan: MealPlan

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var fridgeItems: [FridgeItem]
    @Query private var existingShoppingItems: [ShoppingItem]
    @Query private var allPlannedMeals: [PlannedMeal]

    @State private var shoppingList: CategorizedShoppingList = CategorizedShoppingList(items: [:])
    @State private var expandedCategories: Set<ItemCategory> = Set(ItemCategory.allCases)
    @State private var checkedItems: Set<UUID> = []
    @State private var showingShareSheet = false
    @State private var showingSuccessAlert = false
    @State private var errorMessage: String?
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    loadingView
                } else if shoppingList.isEmpty {
                    emptyStateView
                } else {
                    shoppingListContent
                }
            }
            .navigationTitle("Shopping List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: addAllToShoppingList) {
                            Label("Add All to Shopping List", systemImage: "cart.badge.plus")
                        }

                        Button(action: { showingShareSheet = true }) {
                            Label("Share List", systemImage: "square.and.arrow.up")
                        }

                        Button(action: expandAll) {
                            Label("Expand All", systemImage: "chevron.down.circle")
                        }

                        Button(action: collapseAll) {
                            Label("Collapse All", systemImage: "chevron.up.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.body)
                    }
                }
            }
            .onAppear {
                generateShoppingList()
            }
            .alert("Success", isPresented: $showingSuccessAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("All items have been added to your shopping list!")
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: [generateShareText()])
            }
        }
    }

    // MARK: - Subviews

    private var loadingView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Generating shopping list...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "cart.fill")
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.secondary)

            Text("All Set!")
                .font(.title2)
                .fontWeight(.bold)

            Text("You have all the ingredients you need in your inventory.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
        }
    }

    private var shoppingListContent: some View {
        VStack(spacing: 0) {
            // Summary header
            summaryHeader

            // Shopping list
            ScrollView {
                LazyVStack(spacing: Theme.Spacing.md) {
                    ForEach(shoppingList.allCategories, id: \.self) { category in
                        categorySection(for: category)
                    }
                }
                .padding()
            }

            // Action buttons
            actionButtons
        }
        .background(Theme.Colors.background)
    }

    private var summaryHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Total Items")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(shoppingList.totalItemCount)")
                    .font(.title2)
                    .fontWeight(.bold)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: Theme.Spacing.xs) {
                Text("Categories")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(shoppingList.allCategories.count)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Theme.Colors.cardBackground)
        .shadow(
            color: Theme.Shadow.light.color,
            radius: Theme.Shadow.light.radius,
            x: Theme.Shadow.light.x,
            y: Theme.Shadow.light.y
        )
    }

    private func categorySection(for category: ItemCategory) -> some View {
        let items = shoppingList.items(for: category)

        return VStack(alignment: .leading, spacing: 0) {
            // Category header
            Button(action: { toggleCategory(category) }) {
                HStack {
                    Text(category.icon)
                        .font(.title3)

                    Text(category.rawValue)
                        .font(.headline)

                    Spacer()

                    Text("\(items.count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Image(systemName: expandedCategories.contains(category) ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Theme.Colors.cardBackground)
                .cornerRadius(Theme.CornerRadius.md)
            }
            .buttonStyle(.plain)

            // Category items
            if expandedCategories.contains(category) {
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        shoppingItemRow(item: item)
                            .padding(.leading, Theme.Spacing.xl)
                    }
                }
                .padding(.top, Theme.Spacing.xs)
            }
        }
    }

    private func shoppingItemRow(item: CategorizedShoppingItem) -> some View {
        HStack {
            Button(action: { toggleItemCheck(item) }) {
                Image(systemName: checkedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(checkedItems.contains(item.id) ? Theme.Colors.success : Theme.Colors.secondary)
            }
            .buttonStyle(.plain)

            Text(item.displayText)
                .font(.body)
                .strikethrough(checkedItems.contains(item.id))
                .foregroundColor(checkedItems.contains(item.id) ? .secondary : .primary)

            Spacer()
        }
        .padding(.vertical, Theme.Spacing.sm)
        .padding(.horizontal, Theme.Spacing.md)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.sm)
    }

    private var actionButtons: some View {
        VStack(spacing: Theme.Spacing.md) {
            Button(action: addAllToShoppingList) {
                HStack {
                    Image(systemName: "cart.badge.plus")
                    Text("Add All to Shopping List")
                }
                .primaryButtonStyle(color: Theme.Colors.primary)
            }

            Button(action: { showingShareSheet = true }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share List")
                }
                .secondaryButtonStyle()
            }
        }
        .padding()
        .background(Theme.Colors.cardBackground)
        .shadow(
            color: Theme.Shadow.medium.color,
            radius: Theme.Shadow.medium.radius,
            x: Theme.Shadow.medium.x,
            y: Theme.Shadow.medium.y
        )
    }

    // MARK: - Actions

    private func generateShoppingList() {
        isLoading = true

        // Get meals for this meal plan within the date range
        let mealsForPlan = allPlannedMeals.filter { meal in
            meal.date >= mealPlan.startDate && meal.date <= mealPlan.endDate
        }

        print("🔍 DEBUG: Meal Plan: \(mealPlan.name)")
        print("🔍 DEBUG: Date Range: \(mealPlan.startDate) to \(mealPlan.endDate)")
        print("🔍 DEBUG: Found \(mealsForPlan.count) meals for this plan")
        print("🔍 DEBUG: MealPlan.meals array has \(mealPlan.meals.count) items")

        // Create a temporary meal plan with the fetched meals
        let tempMealPlan = MealPlan(
            id: mealPlan.id,
            name: mealPlan.name,
            goal: mealPlan.goal,
            startDate: mealPlan.startDate,
            endDate: mealPlan.endDate,
            dailyCalorieTarget: mealPlan.dailyCalorieTarget,
            dailyProteinTarget: mealPlan.dailyProteinTarget,
            dailyCarbsTarget: mealPlan.dailyCarbsTarget,
            dailyFatTarget: mealPlan.dailyFatTarget,
            meals: mealsForPlan,
            isActive: mealPlan.isActive
        )

        // Simulate a slight delay for better UX (optional)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Generate the shopping list (this doesn't throw)
            shoppingList = ShoppingListGenerator.shared.generateShoppingList(
                from: tempMealPlan,
                inventory: fridgeItems
            )

            print("🛒 DEBUG: Generated shopping list with \(shoppingList.totalItemCount) items")
            isLoading = false
        }
    }

    private func toggleCategory(_ category: ItemCategory) {
        withAnimation(Theme.Animation.quick) {
            if expandedCategories.contains(category) {
                expandedCategories.remove(category)
            } else {
                expandedCategories.insert(category)
            }
        }
    }

    private func toggleItemCheck(_ item: CategorizedShoppingItem) {
        withAnimation(Theme.Animation.quick) {
            if checkedItems.contains(item.id) {
                checkedItems.remove(item.id)
            } else {
                checkedItems.insert(item.id)
            }
        }
    }

    private func expandAll() {
        withAnimation(Theme.Animation.quick) {
            expandedCategories = Set(shoppingList.allCategories)
        }
    }

    private func collapseAll() {
        withAnimation(Theme.Animation.quick) {
            expandedCategories.removeAll()
        }
    }

    private func addAllToShoppingList() {
        do {
            // Convert categorized list to ShoppingItem models
            let items = ShoppingListGenerator.shared.convertToShoppingItems(shoppingList)

            // Add to database
            for item in items {
                // Check if item already exists
                let existingItem = existingShoppingItems.first { $0.name.lowercased() == item.name.lowercased() }

                if let existing = existingItem {
                    // Update quantity if exists
                    if let existingQty = Int(existing.quantity), let newQty = Int(item.quantity) {
                        existing.quantity = "\(existingQty + newQty)"
                    }
                } else {
                    // Add new item
                    modelContext.insert(item)
                }
            }

            try modelContext.save()
            showingSuccessAlert = true
        } catch {
            errorMessage = "Failed to add items to shopping list: \(error.localizedDescription)"
        }
    }

    private func generateShareText() -> String {
        var text = "Shopping List for \(mealPlan.name)\n"
        text += "Generated on \(Date().formatted(date: .abbreviated, time: .omitted))\n\n"

        for category in shoppingList.allCategories {
            let items = shoppingList.items(for: category)
            text += "\(category.icon) \(category.rawValue):\n"
            for item in items {
                text += "  - \(item.displayText)\n"
            }
            text += "\n"
        }

        text += "Total: \(shoppingList.totalItemCount) items"
        return text
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MealPlan.self, FridgeItem.self, ShoppingItem.self, configurations: config)

    let sampleMealPlan = MealPlan(
        name: "Weight Loss Plan",
        goal: .weightLoss,
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
        dailyCalorieTarget: 1800,
        dailyProteinTarget: 120,
        dailyCarbsTarget: 180,
        dailyFatTarget: 60,
        meals: [
            PlannedMeal(
                date: Date(),
                mealType: .breakfast,
                recipeName: "Oatmeal with Berries",
                recipeInstructions: "Cook oats with milk, top with berries",
                ingredients: ["oats", "milk", "blueberries", "strawberries", "honey"],
                cookingTime: 15,
                prepTime: 30
            ),
            PlannedMeal(
                date: Date(),
                mealType: .lunch,
                recipeName: "Chicken Salad",
                recipeInstructions: "Grill chicken, toss with greens",
                ingredients: ["chicken breast", "lettuce", "tomatoes", "cucumber", "olive oil"],
                cookingTime: 25,
                prepTime: 30
            )
        ]
    )

    container.mainContext.insert(sampleMealPlan)

    return MealPlanShoppingView(mealPlan: sampleMealPlan)
        .modelContainer(container)
}
