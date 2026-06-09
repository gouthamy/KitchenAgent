//
//  MealCalendarView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import SwiftData

struct MealCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var mealPlans: [MealPlan]
    @State private var selectedDate = Date()
    @State private var selectedMeal: PlannedMeal?
    @State private var showMealDetail = false

    private var activeMealPlan: MealPlan? {
        mealPlans.first { $0.isActive }
    }

    private var weekDates: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Week Navigation
                    weekNavigationView

                    // Horizontal 7-day calendar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.Spacing.md) {
                            ForEach(weekDates, id: \.self) { date in
                                dayColumnView(for: date)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                }
                .padding(.vertical, Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Meal Plan")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedDate = Date()
                    }) {
                        Text("Today")
                            .font(.system(size: Theme.FontSize.subheadline, weight: .semibold))
                            .foregroundColor(Theme.Colors.primary)
                    }
                }
            }
            .sheet(item: $selectedMeal) { meal in
                MealDetailView(meal: meal)
            }
        }
    }

    // MARK: - Week Navigation
    private var weekNavigationView: some View {
        HStack {
            Button(action: {
                withAnimation(Theme.Animation.quick) {
                    selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(Theme.Colors.primary)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(monthYearString(for: selectedDate))
                    .font(.system(size: Theme.FontSize.headline, weight: .bold))
                    .foregroundColor(.primary)

                Text("Week \(weekNumber(for: selectedDate))")
                    .font(.system(size: Theme.FontSize.caption))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {
                withAnimation(Theme.Animation.quick) {
                    selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(Theme.Colors.primary)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
    }

    // MARK: - Day Column View
    private func dayColumnView(for date: Date) -> some View {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        let mealsForDay = getMeals(for: date)

        return VStack(spacing: Theme.Spacing.sm) {
            // Day header
            VStack(spacing: 4) {
                Text(dayName(for: date))
                    .font(.system(size: Theme.FontSize.caption, weight: .semibold))
                    .foregroundColor(isToday ? .white : .secondary)

                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: Theme.FontSize.title3, weight: .bold))
                    .foregroundColor(isToday ? .white : .primary)
            }
            .frame(width: 140)
            .padding(.vertical, Theme.Spacing.sm)
            .background(isToday ? Theme.Colors.primary : Color.clear)
            .cornerRadius(Theme.CornerRadius.md)

            // Meals for the day
            VStack(spacing: Theme.Spacing.sm) {
                ForEach(MealType.allCases, id: \.self) { mealType in
                    if let meal = mealsForDay.first(where: { $0.mealType == mealType }) {
                        mealCardView(meal: meal)
                    } else {
                        emptyMealCardView(date: date, mealType: mealType)
                    }
                }
            }
        }
        .frame(width: 140)
    }

    // MARK: - Meal Card View
    private func mealCardView(meal: PlannedMeal) -> some View {
        Button(action: {
            selectedMeal = meal
        }) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack {
                    Image(systemName: meal.mealType.icon)
                        .font(.system(size: 14))
                        .foregroundColor(Theme.Colors.primary)

                    Spacer()

                    if meal.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.Colors.success)
                    }
                }

                Text(meal.mealType.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text(meal.recipeName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if let nutrition = meal.nutrition {
                    Text("\(nutrition.calories) cal")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Theme.Colors.primary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text("\(meal.cookingTime)m")
                        .font(.system(size: 11))
                }
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.Spacing.sm)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.sm)
            .shadow(
                color: Theme.Shadow.light.color,
                radius: Theme.Shadow.light.radius,
                x: Theme.Shadow.light.x,
                y: Theme.Shadow.light.y
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                    .stroke(meal.isCompleted ? Theme.Colors.success : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Empty Meal Card View
    private func emptyMealCardView(date: Date, mealType: MealType) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack {
                Image(systemName: mealType.icon)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                Spacer()
            }

            Text(mealType.rawValue)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .lineLimit(1)

            Text("No meal planned")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.sm)
        .background(Theme.Colors.cardBackground.opacity(0.5))
        .cornerRadius(Theme.CornerRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
        )
    }

    // MARK: - Helper Methods
    private func getMeals(for date: Date) -> [PlannedMeal] {
        guard let plan = activeMealPlan else { return [] }
        let calendar = Calendar.current
        return plan.meals.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func dayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }

    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func weekNumber(for date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.component(.weekOfYear, from: date)
    }
}

#Preview {
    MealCalendarView()
        .modelContainer(for: [MealPlan.self, PlannedMeal.self])
}
