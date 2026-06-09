//
//  MealPlanView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import SwiftData

struct MealPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var mealPlans: [MealPlan]
    @Query private var plannedMeals: [PlannedMeal]

    @State private var selectedDate = Date()
    @State private var showingAddMeal = false
    @State private var showingPlanDetails = false

    private var todaysMeals: [PlannedMeal] {
        let calendar = Calendar.current
        return plannedMeals.filter { meal in
            calendar.isDate(meal.date, inSameDayAs: selectedDate)
        }.sorted { $0.date < $1.date }
    }

    private var activePlan: MealPlan? {
        mealPlans.first(where: { $0.isActive })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    // Date Selector
                    DateSelectorView(selectedDate: $selectedDate)
                        .padding(.horizontal)

                    // Active Meal Plan Info
                    if let plan = activePlan {
                        Button {
                            showingPlanDetails = true
                        } label: {
                            ActivePlanCard(plan: plan)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }

                    // Today's Meals
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        HStack {
                            Text("Meals for \(selectedDate.relativeFormatted)")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            Button {
                                showingAddMeal = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(Theme.Colors.primary)
                            }
                        }
                        .padding(.horizontal)

                        if todaysMeals.isEmpty {
                            EmptyMealsView()
                                .padding(.horizontal)
                        } else {
                            ForEach(todaysMeals) { meal in
                                NavigationLink(destination: MealDetailView(meal: meal)) {
                                    MealCard(meal: meal)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Meal Plan")
            .sheet(isPresented: $showingAddMeal) {
                AddMealView(selectedDate: selectedDate)
            }
            .sheet(isPresented: $showingPlanDetails) {
                if let plan = activePlan {
                    NavigationStack {
                        MealPlanDetailView(mealPlan: plan)
                    }
                }
            }
        }
    }
}

// MARK: - Date Selector
struct DateSelectorView: View {
    @Binding var selectedDate: Date

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.md) {
                ForEach(-3..<4, id: \.self) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
                    DateButton(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate)) {
                        selectedDate = date
                    }
                }
            }
        }
    }
}

// DateButton moved to Views/Components/DateButton.swift

// MARK: - Active Plan Card
struct ActivePlanCard: View {
    let plan: MealPlan

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(Theme.Colors.primary)
                Text(plan.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text(plan.goal.rawValue)
                    .font(.caption)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, Theme.Spacing.xs)
                    .background(Theme.Colors.primary.opacity(0.2))
                    .foregroundColor(Theme.Colors.primary)
                    .cornerRadius(Theme.CornerRadius.sm)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: Theme.Spacing.xl) {
                MacroView(label: "Cal", value: "\(plan.dailyCalorieTarget)", color: .orange)
                MacroView(label: "Protein", value: "\(Int(plan.dailyProteinTarget))g", color: .red)
                MacroView(label: "Carbs", value: "\(Int(plan.dailyCarbsTarget))g", color: .blue)
                MacroView(label: "Fat", value: "\(Int(plan.dailyFatTarget))g", color: .purple)
            }
        }
        .padding()
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
        .shadow(
            color: Theme.Shadow.light.color,
            radius: Theme.Shadow.light.radius,
            x: Theme.Shadow.light.x,
            y: Theme.Shadow.light.y
        )
    }
}

struct MacroView: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text(value)
                .font(.headline)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Meal Card
struct MealCard: View {
    let meal: PlannedMeal

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Meal Type Icon
            Circle()
                .fill(Theme.Colors.primary.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: meal.mealType.icon)
                        .foregroundColor(Theme.Colors.primary)
                )

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(meal.mealType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(meal.recipeName)
                    .font(.headline)
                HStack(spacing: Theme.Spacing.sm) {
                    Label("\(meal.cookingTime) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let nutrition = meal.nutrition {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text("\(nutrition.calories) cal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            if meal.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            }
        }
        .padding()
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
        .shadow(
            color: Theme.Shadow.light.color,
            radius: Theme.Shadow.light.radius,
            x: Theme.Shadow.light.x,
            y: Theme.Shadow.light.y
        )
    }
}

// MARK: - Empty State
struct EmptyMealsView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No meals planned")
                .font(.headline)
            Text("Tap + to add a meal")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xxl)
        .background(Theme.Colors.background)
        .cornerRadius(Theme.CornerRadius.md)
    }
}

// MARK: - Add Meal View
struct AddMealView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let selectedDate: Date

    @State private var showingCreatePlan = false

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.xl) {
                Spacer()

                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.Colors.primary)

                Text("Create a Meal Plan First")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Generate a complete 7-day meal plan with ChatGPT, including breakfast, lunch, dinner, and snacks.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)

                Button {
                    showingCreatePlan = true
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Create Meal Plan")
                            .fontWeight(.semibold)
                    }
                    .primaryButtonStyle(color: Theme.Colors.primary)
                }
                .padding(.horizontal, Theme.Spacing.xl)

                Spacer()
            }
            .navigationTitle("Add Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCreatePlan) {
                MealPlanCreatorView()
            }
        }
    }
}

#Preview {
    MealPlanView()
        .modelContainer(for: [MealPlan.self, PlannedMeal.self], inMemory: true)
}
