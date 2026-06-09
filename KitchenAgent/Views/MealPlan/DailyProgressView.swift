//
//  DailyProgressView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import SwiftData

struct DailyProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var mealPlans: [MealPlan]
    @State private var selectedDate = Date()
    @State private var showDatePicker = false

    private var activeMealPlan: MealPlan? {
        mealPlans.first { $0.isActive }
    }

    private var todayMeals: [PlannedMeal] {
        guard let plan = activeMealPlan else { return [] }
        let calendar = Calendar.current
        return plan.meals.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
    }

    private var totalNutrition: (calories: Int, protein: Double, carbs: Double, fat: Double) {
        var calories = 0
        var protein = 0.0
        var carbs = 0.0
        var fat = 0.0

        for meal in todayMeals where meal.isCompleted {
            if let nutrition = meal.nutrition {
                calories += nutrition.calories
                protein += nutrition.protein
                carbs += nutrition.carbs
                fat += nutrition.fat
            }
        }

        return (calories, protein, carbs, fat)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Date Selector
                    dateSelectorView

                    // Progress Summary
                    if let plan = activeMealPlan {
                        progressSummaryView(plan: plan)
                    } else {
                        emptyStateView
                    }

                    // Today's Meals List
                    if !todayMeals.isEmpty {
                        mealsListView
                    }

                    // Motivational Message
                    motivationalCardView
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Daily Progress")
            .sheet(isPresented: $showDatePicker) {
                datePickerSheet
            }
        }
    }

    // MARK: - Date Selector
    private var dateSelectorView: some View {
        Button(action: {
            showDatePicker = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatDateFull(selectedDate))
                        .font(.system(size: Theme.FontSize.title3, weight: .bold))
                        .foregroundColor(.primary)

                    Text(isToday(selectedDate) ? "Today" : daysSince(selectedDate))
                        .font(.system(size: Theme.FontSize.subheadline))
                        .foregroundColor(Theme.Colors.primary)
                }

                Spacer()

                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(Theme.Colors.primary)
            }
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Progress Summary
    private func progressSummaryView(plan: MealPlan) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            Text("Nutrition Progress")
                .font(.system(size: Theme.FontSize.headline, weight: .bold))
                .foregroundColor(.primary)

            // Progress Rings
            HStack(spacing: Theme.Spacing.md) {
                progressRingView(
                    label: "Calories",
                    current: totalNutrition.calories,
                    target: plan.dailyCalorieTarget,
                    unit: "",
                    color: Theme.Colors.primary
                )

                progressRingView(
                    label: "Protein",
                    current: Int(totalNutrition.protein),
                    target: Int(plan.dailyProteinTarget),
                    unit: "g",
                    color: Theme.Colors.success
                )
            }

            HStack(spacing: Theme.Spacing.md) {
                progressRingView(
                    label: "Carbs",
                    current: Int(totalNutrition.carbs),
                    target: Int(plan.dailyCarbsTarget),
                    unit: "g",
                    color: Theme.Colors.warning
                )

                progressRingView(
                    label: "Fat",
                    current: Int(totalNutrition.fat),
                    target: Int(plan.dailyFatTarget),
                    unit: "g",
                    color: Theme.Colors.accent
                )
            }

            // Completion Stats
            Divider()

            HStack(spacing: Theme.Spacing.xl) {
                statItem(
                    icon: "checkmark.circle.fill",
                    value: "\(completedMealsCount)",
                    label: "Completed",
                    color: Theme.Colors.success
                )

                statItem(
                    icon: "clock.fill",
                    value: "\(remainingMealsCount)",
                    label: "Remaining",
                    color: Theme.Colors.warning
                )

                statItem(
                    icon: "fork.knife",
                    value: "\(todayMeals.count)",
                    label: "Total Meals",
                    color: Theme.Colors.primary
                )
            }
        }
        .cardStyle()
    }

    // MARK: - Progress Ring View
    private func progressRingView(label: String, current: Int, target: Int, unit: String, color: Color) -> some View {
        let progress = min(Double(current) / Double(max(target, 1)), 1.0)

        return VStack(spacing: Theme.Spacing.sm) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 10)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(Theme.Animation.normal, value: progress)

                VStack(spacing: 0) {
                    Text("\(current)")
                        .font(.system(size: Theme.FontSize.headline, weight: .bold))
                        .foregroundColor(.primary)
                    Text("/ \(target)\(unit)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }

            Text(label)
                .font(.system(size: Theme.FontSize.subheadline, weight: .medium))
                .foregroundColor(.primary)

            Text("\(Int(progress * 100))%")
                .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Stat Item
    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: Theme.FontSize.title2, weight: .bold))
                .foregroundColor(.primary)

            Text(label)
                .font(.system(size: Theme.FontSize.caption))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Meals List
    private var mealsListView: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Today's Meals")
                .font(.system(size: Theme.FontSize.headline, weight: .bold))
                .foregroundColor(.primary)

            VStack(spacing: Theme.Spacing.sm) {
                ForEach(todayMeals.sorted(by: { $0.date < $1.date })) { meal in
                    mealRowView(meal: meal)
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Meal Row View
    private func mealRowView(meal: PlannedMeal) -> some View {
        Button(action: {
            withAnimation(Theme.Animation.quick) {
                meal.isCompleted.toggle()
            }
        }) {
            HStack(spacing: Theme.Spacing.md) {
                // Checkbox
                Image(systemName: meal.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(meal.isCompleted ? Theme.Colors.success : .secondary)

                // Meal Icon
                Image(systemName: meal.mealType.icon)
                    .font(.system(size: 20))
                    .foregroundColor(Theme.Colors.primary)
                    .frame(width: 32)

                // Meal Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(meal.recipeName)
                        .font(.system(size: Theme.FontSize.body, weight: .semibold))
                        .foregroundColor(.primary)
                        .strikethrough(meal.isCompleted)

                    HStack(spacing: Theme.Spacing.sm) {
                        Text(meal.mealType.rawValue)
                            .font(.system(size: Theme.FontSize.caption))
                            .foregroundColor(.secondary)

                        if let nutrition = meal.nutrition {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text("\(nutrition.calories) cal")
                                .font(.system(size: Theme.FontSize.caption))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                // Time
                Text(formatTime(meal.date))
                    .font(.system(size: Theme.FontSize.subheadline, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(Theme.Spacing.sm)
            .background(meal.isCompleted ? Theme.Colors.success.opacity(0.1) : Theme.Colors.background)
            .cornerRadius(Theme.CornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                    .stroke(meal.isCompleted ? Theme.Colors.success : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Motivational Card
    private var motivationalCardView: some View {
        let progress = Double(completedMealsCount) / Double(max(todayMeals.count, 1))
        let message = getMotivationalMessage(progress: progress)

        return HStack(spacing: Theme.Spacing.md) {
            Image(systemName: message.icon)
                .font(.system(size: 32))
                .foregroundColor(message.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(message.title)
                    .font(.system(size: Theme.FontSize.headline, weight: .bold))
                    .foregroundColor(.primary)

                Text(message.subtitle)
                    .font(.system(size: Theme.FontSize.subheadline))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(Theme.Spacing.md)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [message.color.opacity(0.2), message.color.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(Theme.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                .stroke(message.color.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("No Active Meal Plan")
                .font(.system(size: Theme.FontSize.title3, weight: .bold))
                .foregroundColor(.primary)

            Text("Create a meal plan to track your daily progress")
                .font(.system(size: Theme.FontSize.body))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.xxl)
        .cardStyle()
    }

    // MARK: - Date Picker Sheet
    private var datePickerSheet: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()

                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showDatePicker = false
                    }
                }
            }
        }
    }

    // MARK: - Helper Properties
    private var completedMealsCount: Int {
        todayMeals.filter { $0.isCompleted }.count
    }

    private var remainingMealsCount: Int {
        todayMeals.count - completedMealsCount
    }

    // MARK: - Helper Methods
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDateFull(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    private func daysSince(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        if days == 0 {
            return "Today"
        } else if days == -1 {
            return "Tomorrow"
        } else if days == 1 {
            return "Yesterday"
        } else if days < 0 {
            return "\(abs(days)) days ahead"
        } else {
            return "\(days) days ago"
        }
    }

    private func getMotivationalMessage(progress: Double) -> (title: String, subtitle: String, icon: String, color: Color) {
        if progress == 0 {
            return (
                "Start Your Day!",
                "Time to fuel your body with nutritious meals",
                "sunrise.fill",
                Theme.Colors.warning
            )
        } else if progress < 0.5 {
            return (
                "Keep Going!",
                "You're making great progress",
                "flame.fill",
                Theme.Colors.primary
            )
        } else if progress < 1.0 {
            return (
                "Almost There!",
                "Just a few more meals to complete",
                "star.fill",
                Theme.Colors.accent
            )
        } else {
            return (
                "Perfect Day!",
                "You've completed all your meals",
                "checkmark.seal.fill",
                Theme.Colors.success
            )
        }
    }
}

#Preview {
    DailyProgressView()
        .modelContainer(for: [MealPlan.self, PlannedMeal.self])
}
