//
//  MealDetailView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import UserNotifications

struct MealDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var meal: PlannedMeal

    @State private var showReminderAlert = false
    @State private var reminderMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Header Card
                    headerCardView

                    // Nutrition Panel
                    if let nutrition = meal.nutrition {
                        nutritionPanelView(nutrition: nutrition)
                    }

                    // Ingredients Section
                    ingredientsSectionView

                    // Instructions Section
                    instructionsSectionView

                    // Action Buttons
                    actionButtonsView
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Meal Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.title3)
                    }
                }
            }
            .alert("Reminder", isPresented: $showReminderAlert) {
                Button("OK") { }
            } message: {
                Text(reminderMessage)
            }
        }
    }

    // MARK: - Header Card
    private var headerCardView: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(meal.mealType.rawValue)
                        .font(.system(size: Theme.FontSize.subheadline, weight: .semibold))
                        .foregroundColor(Theme.Colors.primary)

                    Text(meal.recipeName)
                        .font(.system(size: Theme.FontSize.title2, weight: .bold))
                        .foregroundColor(.primary)
                }

                Spacer()

                Image(systemName: meal.mealType.icon)
                    .font(.system(size: 40))
                    .foregroundColor(Theme.Colors.primary.opacity(0.3))
            }

            Divider()

            HStack(spacing: Theme.Spacing.lg) {
                mealInfoItem(icon: "clock", text: "\(meal.cookingTime) min", label: "Cook Time")
                mealInfoItem(icon: "alarm", text: formatTime(meal.date), label: "Scheduled")
                mealInfoItem(icon: "calendar", text: formatDate(meal.date), label: "Date")
            }
        }
        .cardStyle()
    }

    // MARK: - Nutrition Panel
    private func nutritionPanelView(nutrition: NutritionData) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Nutrition Facts")
                .font(.system(size: Theme.FontSize.headline, weight: .bold))
                .foregroundColor(.primary)

            // Calories with Progress Ring
            HStack(spacing: Theme.Spacing.md) {
                ZStack {
                    Circle()
                        .stroke(Theme.Colors.primary.opacity(0.2), lineWidth: 12)
                        .frame(width: 100, height: 100)

                    Circle()
                        .trim(from: 0, to: min(Double(nutrition.calories) / 2000.0, 1.0))
                        .stroke(
                            Theme.Colors.primary,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(nutrition.calories)")
                            .font(.system(size: Theme.FontSize.title2, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Calories")
                            .font(.system(size: Theme.FontSize.caption))
                            .foregroundColor(.secondary)
                    }
                }

                VStack(spacing: Theme.Spacing.sm) {
                    macroBarView(
                        label: "Protein",
                        value: nutrition.protein,
                        unit: "g",
                        color: Theme.Colors.primary,
                        progress: nutrition.protein / 150.0
                    )
                    macroBarView(
                        label: "Carbs",
                        value: nutrition.carbs,
                        unit: "g",
                        color: Theme.Colors.warning,
                        progress: nutrition.carbs / 300.0
                    )
                    macroBarView(
                        label: "Fat",
                        value: nutrition.fat,
                        unit: "g",
                        color: Theme.Colors.accent,
                        progress: nutrition.fat / 70.0
                    )
                }
            }

            Divider()

            // Additional Nutrients
            HStack(spacing: Theme.Spacing.xl) {
                nutritionDetailItem(label: "Fiber", value: nutrition.fiber, unit: "g")
                nutritionDetailItem(label: "Sugar", value: nutrition.sugar, unit: "g")
            }
        }
        .cardStyle()
    }

    // MARK: - Macro Bar View
    private func macroBarView(label: String, value: Double, unit: String, color: Color, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: Theme.FontSize.subheadline, weight: .medium))
                    .foregroundColor(.primary)
                Spacer()
                Text(String(format: "%.1f%@", value, unit))
                    .font(.system(size: Theme.FontSize.subheadline, weight: .semibold))
                    .foregroundColor(color)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                        .fill(color.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                        .fill(color)
                        .frame(width: geometry.size.width * min(progress, 1.0), height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - Nutrition Detail Item
    private func nutritionDetailItem(label: String, value: Double, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(String(format: "%.1f%@", value, unit))
                .font(.system(size: Theme.FontSize.title3, weight: .bold))
                .foregroundColor(.primary)
            Text(label)
                .font(.system(size: Theme.FontSize.caption))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.sm)
        .background(Theme.Colors.background)
        .cornerRadius(Theme.CornerRadius.sm)
    }

    // MARK: - Ingredients Section
    private var ingredientsSectionView: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Image(systemName: "cart.fill")
                    .foregroundColor(Theme.Colors.primary)
                Text("Ingredients")
                    .font(.system(size: Theme.FontSize.headline, weight: .bold))
                    .foregroundColor(.primary)
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                ForEach(Array(meal.ingredients.enumerated()), id: \.offset) { index, ingredient in
                    HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                        Text("\(index + 1).")
                            .font(.system(size: Theme.FontSize.body, weight: .semibold))
                            .foregroundColor(Theme.Colors.primary)
                            .frame(width: 24, alignment: .leading)

                        Text(ingredient)
                            .font(.system(size: Theme.FontSize.body))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 4)

                    if index < meal.ingredients.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Instructions Section
    private var instructionsSectionView: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(Theme.Colors.primary)
                Text("Cooking Instructions")
                    .font(.system(size: Theme.FontSize.headline, weight: .bold))
                    .foregroundColor(.primary)
            }

            Text(meal.recipeInstructions)
                .font(.system(size: Theme.FontSize.body))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(6)
        }
        .cardStyle()
    }

    // MARK: - Action Buttons
    private var actionButtonsView: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Mark as Eaten Button
            Button(action: {
                withAnimation(Theme.Animation.quick) {
                    meal.isCompleted.toggle()
                }
            }) {
                HStack {
                    Image(systemName: meal.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                    Text(meal.isCompleted ? "Marked as Eaten" : "Mark as Eaten")
                        .font(.system(size: Theme.FontSize.headline, weight: .semibold))
                }
            }
            .primaryButtonStyle(color: meal.isCompleted ? Theme.Colors.success : Theme.Colors.primary)

            // Set Reminder Button
            Button(action: {
                setReminder()
            }) {
                HStack {
                    Image(systemName: meal.reminderSet ? "bell.fill" : "bell")
                        .font(.title3)
                    Text(meal.reminderSet ? "Reminder Set" : "Set Reminder")
                        .font(.system(size: Theme.FontSize.headline, weight: .semibold))
                }
            }
            .secondaryButtonStyle()
        }
    }

    // MARK: - Helper Views
    private func mealInfoItem(icon: String, text: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Theme.Colors.primary)

            Text(text)
                .font(.system(size: Theme.FontSize.subheadline, weight: .semibold))
                .foregroundColor(.primary)

            Text(label)
                .font(.system(size: Theme.FontSize.caption))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helper Methods
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func setReminder() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    scheduleNotification()
                    meal.reminderSet = true
                    reminderMessage = "Reminder set for \(meal.cookingTime) minutes before meal time"
                } else {
                    reminderMessage = "Please enable notifications in Settings"
                }
                showReminderAlert = true
            }
        }
    }

    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time to Cook!"
        content.body = "Start preparing \(meal.recipeName) for \(meal.mealType.rawValue)"
        content.sound = .default

        let triggerDate = meal.cookingStartTime
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: meal.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}

#Preview {
    let meal = PlannedMeal(
        date: Date(),
        mealType: .lunch,
        recipeName: "Grilled Chicken Salad",
        recipeInstructions: "1. Grill the chicken until cooked through.\n2. Chop fresh vegetables.\n3. Mix everything together with dressing.",
        ingredients: [
            "2 chicken breasts",
            "Mixed salad greens",
            "Cherry tomatoes",
            "Cucumber",
            "Olive oil dressing"
        ],
        nutrition: NutritionData(
            calories: 450,
            protein: 35.0,
            carbs: 25.0,
            fat: 22.0,
            fiber: 6.0,
            sugar: 8.0
        ),
        cookingTime: 25
    )

    return MealDetailView(meal: meal)
}
