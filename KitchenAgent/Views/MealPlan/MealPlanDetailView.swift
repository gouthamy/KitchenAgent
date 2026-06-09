//
//  MealPlanDetailView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import SwiftData

/// Example view showing how to use the Shopping List Generator and Meal Reminders
struct MealPlanDetailView: View {
    let mealPlan: MealPlan

    @Environment(\.modelContext) private var modelContext
    @Query private var allPlannedMeals: [PlannedMeal]
    @State private var showingShoppingList = false
    @State private var remindersEnabled = false
    @State private var showingReminderAlert = false
    @State private var reminderMessage = ""

    private var mealsForPlan: [PlannedMeal] {
        allPlannedMeals.filter { meal in
            meal.date >= mealPlan.startDate && meal.date <= mealPlan.endDate
        }.sorted { $0.date < $1.date }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                // Meal Plan Header
                headerSection

                // Meals List
                mealsSection

                // Action Buttons
                actionButtons
            }
            .padding()
        }
        .navigationTitle(mealPlan.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShoppingList) {
            MealPlanShoppingView(mealPlan: mealPlan)
        }
        .alert("Reminders", isPresented: $showingReminderAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(reminderMessage)
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Text(mealPlan.goal.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.xs)
                    .background(Theme.Colors.primary.opacity(0.2))
                    .foregroundColor(Theme.Colors.primary)
                    .cornerRadius(Theme.CornerRadius.full)

                Spacer()

                if mealPlan.isActive {
                    Text("Active")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, Theme.Spacing.xs)
                        .background(Theme.Colors.success)
                        .cornerRadius(Theme.CornerRadius.full)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Start Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(mealPlan.startDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: Theme.Spacing.xs) {
                    Text("End Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(mealPlan.endDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }

            Divider()

            // Nutrition targets
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Daily Targets")
                    .font(.headline)

                HStack {
                    nutritionBadge(title: "Calories", value: "\(mealPlan.dailyCalorieTarget)")
                    nutritionBadge(title: "Protein", value: "\(Int(mealPlan.dailyProteinTarget))g")
                    nutritionBadge(title: "Carbs", value: "\(Int(mealPlan.dailyCarbsTarget))g")
                    nutritionBadge(title: "Fat", value: "\(Int(mealPlan.dailyFatTarget))g")
                }
            }
        }
        .cardStyle()
    }

    private func nutritionBadge(title: String, value: String) -> some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xs)
        .background(Theme.Colors.background)
        .cornerRadius(Theme.CornerRadius.sm)
    }

    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Meals (\(mealsForPlan.count))")
                .font(.headline)

            if mealsForPlan.isEmpty {
                Text("No meals generated yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(mealsForPlan) { meal in
                    mealCard(meal: meal)
                }
            }
        }
    }

    private func mealCard(meal: PlannedMeal) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: meal.mealType.icon)
                    .foregroundColor(Theme.Colors.primary)

                VStack(alignment: .leading) {
                    Text(meal.mealType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(meal.recipeName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Spacer()

                if meal.reminderSet {
                    Image(systemName: "bell.fill")
                        .font(.caption)
                        .foregroundColor(Theme.Colors.warning)
                }
            }

            HStack {
                Label("\(meal.cookingTime) min", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(meal.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .cardStyle()
    }

    private var actionButtons: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Generate Shopping List Button
            Button(action: { showingShoppingList = true }) {
                HStack {
                    Image(systemName: "cart.fill")
                    Text("Generate Shopping List")
                }
                .primaryButtonStyle(color: Theme.Colors.primary)
            }

            // Set Reminders Button
            Button(action: scheduleAllReminders) {
                HStack {
                    Image(systemName: remindersEnabled ? "bell.fill" : "bell")
                    Text(remindersEnabled ? "Reminders Set" : "Set Cooking Reminders")
                }
                .primaryButtonStyle(color: remindersEnabled ? Theme.Colors.success : Theme.Colors.warning)
            }
            .disabled(remindersEnabled)

            // Cancel Reminders Button (if reminders are set)
            if remindersEnabled {
                Button(action: cancelAllReminders) {
                    HStack {
                        Image(systemName: "bell.slash")
                        Text("Cancel All Reminders")
                    }
                    .destructiveButtonStyle()
                }
            }
        }
    }

    // MARK: - Actions

    private func scheduleAllReminders() {
        Task {
            do {
                // Request notification permission
                let authorized = try await NotificationService.shared.requestAuthorization()

                guard authorized else {
                    reminderMessage = "Please enable notifications in Settings to receive cooking reminders."
                    showingReminderAlert = true
                    return
                }

                // Schedule reminders for all meals
                var successCount = 0
                for meal in mealPlan.meals {
                    do {
                        try NotificationService.shared.scheduleMealReminder(for: meal)
                        meal.reminderSet = true
                        successCount += 1
                    } catch {
                        print("Failed to schedule reminder for \(meal.recipeName): \(error.localizedDescription)")
                    }
                }

                try modelContext.save()

                remindersEnabled = true
                reminderMessage = "Successfully scheduled \(successCount) cooking reminders!"
                showingReminderAlert = true
            } catch {
                reminderMessage = "Failed to schedule reminders: \(error.localizedDescription)"
                showingReminderAlert = true
            }
        }
    }

    private func cancelAllReminders() {
        // Cancel all meal reminders
        for meal in mealPlan.meals {
            NotificationService.shared.cancelMealReminder(for: meal.id)
            meal.reminderSet = false
        }

        do {
            try modelContext.save()
            remindersEnabled = false
            reminderMessage = "All cooking reminders have been cancelled."
            showingReminderAlert = true
        } catch {
            reminderMessage = "Failed to cancel reminders: \(error.localizedDescription)"
            showingReminderAlert = true
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MealPlan.self, configurations: config)

    let sampleNutrition = NutritionData(
        calories: 450,
        protein: 30,
        carbs: 45,
        fat: 15,
        fiber: 8,
        sugar: 5
    )

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
                date: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!,
                mealType: .breakfast,
                recipeName: "Oatmeal with Berries",
                recipeInstructions: "Cook oats with milk, top with berries and honey",
                ingredients: ["1 cup oats", "1 cup milk", "1/2 cup blueberries", "1/2 cup strawberries", "1 tbsp honey"],
                nutrition: sampleNutrition,
                cookingTime: 15,
                prepTime: 30
            ),
            PlannedMeal(
                date: Calendar.current.date(byAdding: .hour, value: 5, to: Date())!,
                mealType: .lunch,
                recipeName: "Grilled Chicken Salad",
                recipeInstructions: "Grill chicken breast, toss with mixed greens and vegetables",
                ingredients: ["1 chicken breast", "2 cups lettuce", "1 tomato", "1 cucumber", "2 tbsp olive oil"],
                nutrition: sampleNutrition,
                cookingTime: 25,
                prepTime: 30
            ),
            PlannedMeal(
                date: Calendar.current.date(byAdding: .hour, value: 10, to: Date())!,
                mealType: .dinner,
                recipeName: "Salmon with Vegetables",
                recipeInstructions: "Bake salmon with roasted vegetables",
                ingredients: ["1 salmon fillet", "2 cups broccoli", "1 bell pepper", "1 onion", "olive oil"],
                nutrition: sampleNutrition,
                cookingTime: 30,
                prepTime: 30
            )
        ],
        isActive: true
    )

    container.mainContext.insert(sampleMealPlan)

    return NavigationStack {
        MealPlanDetailView(mealPlan: sampleMealPlan)
    }
    .modelContainer(container)
}
