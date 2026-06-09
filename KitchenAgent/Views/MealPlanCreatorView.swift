//
//  MealPlanCreatorView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import SwiftData

struct MealPlanCreatorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [UserSettings]

    // MARK: - Personal Info
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var gender: Gender = .male
    @State private var activityLevel: ActivityLevel = .moderate

    // MARK: - Goal Selection
    @State private var selectedGoal: DietGoal = .maintenance

    // MARK: - Duration
    @State private var duration: PlanDuration = .oneWeek

    // MARK: - Calculated Values
    @State private var calculatedCalories: Int = 0
    @State private var calculatedProtein: Double = 0
    @State private var calculatedCarbs: Double = 0
    @State private var calculatedFat: Double = 0

    // MARK: - UI State
    @State private var showValidationError = false
    @State private var validationMessage = ""
    @State private var isGenerating = false
    @State private var showSuccessAlert = false
    @State private var generationProgress = ""

    // MARK: - Computed Properties
    private var userSettings: UserSettings? {
        settings.first
    }

    private var isFormValid: Bool {
        guard let ageInt = Int(age), ageInt > 0 && ageInt < 120,
              let weightDouble = Double(weight), weightDouble > 0,
              let heightDouble = Double(height), heightDouble > 0 else {
            return false
        }
        return true
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Header Card
                    headerCard

                    // Goal Selection
                    goalSelectionCard

                    // Personal Information
                    personalInfoCard

                    // Activity Level
                    activityLevelCard

                    // Calculated Nutrition Targets
                    nutritionTargetsCard

                    // Duration Selection
                    durationSelectionCard

                    // Generate Button
                    generateButton
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Create Meal Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Validation Error", isPresented: $showValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
            .alert("Success!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your meal plan has been created successfully!")
            }
            .onChange(of: age) { calculateNutrition() }
            .onChange(of: weight) { calculateNutrition() }
            .onChange(of: height) { calculateNutrition() }
            .onChange(of: gender) { calculateNutrition() }
            .onChange(of: activityLevel) { calculateNutrition() }
            .onChange(of: selectedGoal) { calculateNutrition() }
        }
    }

    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(Theme.Colors.primary)

            Text("Plan Your Nutrition Journey")
                .font(.title2)
                .fontWeight(.bold)

            Text("Tell us about yourself and your goals, and we'll create a personalized meal plan for you")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(Theme.Spacing.lg)
        .cardStyle()
    }

    // MARK: - Goal Selection Card
    private var goalSelectionCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("Your Diet Goal", systemImage: "target")
                .font(.headline)
                .foregroundColor(Theme.Colors.primary)

            ForEach(DietGoal.allCases, id: \.self) { goal in
                GoalOptionView(
                    goal: goal,
                    isSelected: selectedGoal == goal,
                    action: { selectedGoal = goal }
                )
            }
        }
        .padding(Theme.Spacing.lg)
        .cardStyle()
    }

    // MARK: - Personal Info Card
    private var personalInfoCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("Personal Information", systemImage: "person.fill")
                .font(.headline)
                .foregroundColor(Theme.Colors.primary)

            VStack(spacing: Theme.Spacing.md) {
                // Age
                HStack {
                    Text("Age")
                        .frame(width: 80, alignment: .leading)
                    TextField("25", text: $age)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text("years")
                        .foregroundColor(.secondary)
                }

                // Weight
                HStack {
                    Text("Weight")
                        .frame(width: 80, alignment: .leading)
                    TextField("70", text: $weight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text("kg")
                        .foregroundColor(.secondary)
                }

                // Height
                HStack {
                    Text("Height")
                        .frame(width: 80, alignment: .leading)
                    TextField("170", text: $height)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text("cm")
                        .foregroundColor(.secondary)
                }

                // Gender
                HStack {
                    Text("Gender")
                        .frame(width: 80, alignment: .leading)
                    Picker("Gender", selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
        .padding(Theme.Spacing.lg)
        .cardStyle()
    }

    // MARK: - Activity Level Card
    private var activityLevelCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("Activity Level", systemImage: "figure.walk")
                .font(.headline)
                .foregroundColor(Theme.Colors.primary)

            ForEach(ActivityLevel.allCases, id: \.self) { level in
                ActivityLevelOptionView(
                    level: level,
                    isSelected: activityLevel == level,
                    action: { activityLevel = level }
                )
            }
        }
        .padding(Theme.Spacing.lg)
        .cardStyle()
    }

    // MARK: - Nutrition Targets Card
    private var nutritionTargetsCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("Daily Nutrition Targets", systemImage: "chart.bar.fill")
                .font(.headline)
                .foregroundColor(Theme.Colors.primary)

            if calculatedCalories > 0 {
                VStack(spacing: Theme.Spacing.sm) {
                    NutritionTargetRow(
                        icon: "flame.fill",
                        label: "Calories",
                        value: "\(calculatedCalories)",
                        unit: "kcal",
                        color: .orange
                    )

                    Divider()

                    NutritionTargetRow(
                        icon: "bolt.fill",
                        label: "Protein",
                        value: String(format: "%.0f", calculatedProtein),
                        unit: "g",
                        color: .red
                    )

                    Divider()

                    NutritionTargetRow(
                        icon: "leaf.fill",
                        label: "Carbs",
                        value: String(format: "%.0f", calculatedCarbs),
                        unit: "g",
                        color: .blue
                    )

                    Divider()

                    NutritionTargetRow(
                        icon: "drop.fill",
                        label: "Fat",
                        value: String(format: "%.0f", calculatedFat),
                        unit: "g",
                        color: .yellow
                    )
                }
            } else {
                Text("Fill in your personal information to calculate your nutrition targets")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, Theme.Spacing.sm)
            }
        }
        .padding(Theme.Spacing.lg)
        .cardStyle()
    }

    // MARK: - Duration Selection Card
    private var durationSelectionCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Label("Plan Duration", systemImage: "calendar")
                .font(.headline)
                .foregroundColor(Theme.Colors.primary)

            HStack(spacing: Theme.Spacing.sm) {
                ForEach(PlanDuration.allCases, id: \.self) { planDuration in
                    Button {
                        duration = planDuration
                    } label: {
                        VStack(spacing: Theme.Spacing.xs) {
                            Text(planDuration.displayName)
                                .font(.headline)
                            Text("\(planDuration.days) days")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.md)
                        .background(
                            duration == planDuration
                                ? Theme.Colors.primary
                                : Theme.Colors.background
                        )
                        .foregroundColor(
                            duration == planDuration
                                ? .white
                                : .primary
                        )
                        .cornerRadius(Theme.CornerRadius.md)
                    }
                }
            }
        }
        .padding(Theme.Spacing.lg)
        .cardStyle()
    }

    // MARK: - Generate Button
    private var generateButton: some View {
        Button {
            generateMealPlan()
        } label: {
            HStack {
                if isGenerating {
                    ProgressView()
                        .tint(.white)
                }
                VStack(spacing: 4) {
                    Text(isGenerating ? "Generating..." : "Generate Meal Plan")
                        .fontWeight(.semibold)
                    if isGenerating && !generationProgress.isEmpty {
                        Text(generationProgress)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isFormValid && !isGenerating ? Theme.Colors.primary : Theme.Colors.secondary)
            .foregroundColor(.white)
            .cornerRadius(Theme.CornerRadius.md)
        }
        .disabled(!isFormValid || isGenerating)
        .padding(.top, Theme.Spacing.sm)
    }

    // MARK: - Calculation Logic
    private func calculateNutrition() {
        guard let ageInt = Int(age),
              let weightDouble = Double(weight),
              let heightDouble = Double(height) else {
            calculatedCalories = 0
            return
        }

        // Calculate BMR using Mifflin-St Jeor Equation
        let bmr: Double
        if gender == .male {
            bmr = (10 * weightDouble) + (6.25 * heightDouble) - (5 * Double(ageInt)) + 5
        } else {
            bmr = (10 * weightDouble) + (6.25 * heightDouble) - (5 * Double(ageInt)) - 161
        }

        // Apply activity level multiplier
        let tdee = bmr * activityLevel.multiplier

        // Apply goal modifier
        let targetCalories = tdee * selectedGoal.calorieModifier

        calculatedCalories = Int(targetCalories)

        // Calculate macros based on goal
        switch selectedGoal {
        case .weightLoss:
            // Higher protein for weight loss (40% protein, 30% carbs, 30% fat)
            calculatedProtein = (targetCalories * 0.40) / 4 // 4 cal per gram
            calculatedCarbs = (targetCalories * 0.30) / 4
            calculatedFat = (targetCalories * 0.30) / 9 // 9 cal per gram

        case .muscleGain:
            // Balanced with higher carbs (30% protein, 45% carbs, 25% fat)
            calculatedProtein = (targetCalories * 0.30) / 4
            calculatedCarbs = (targetCalories * 0.45) / 4
            calculatedFat = (targetCalories * 0.25) / 9

        case .maintenance, .healthyEating:
            // Balanced macros (30% protein, 40% carbs, 30% fat)
            calculatedProtein = (targetCalories * 0.30) / 4
            calculatedCarbs = (targetCalories * 0.40) / 4
            calculatedFat = (targetCalories * 0.30) / 9
        }
    }

    // MARK: - Generate Meal Plan
    private func generateMealPlan() {
        // Validate form
        guard isFormValid else {
            validationMessage = "Please fill in all fields with valid values"
            showValidationError = true
            return
        }

        guard calculatedCalories > 0 else {
            validationMessage = "Unable to calculate nutrition targets. Please check your inputs."
            showValidationError = true
            return
        }

        isGenerating = true

        // Generate meal plan with ChatGPT
        Task {
            do {
                print("🚀 Starting meal plan generation...")
                try await createMealPlanWithAI()
                await MainActor.run {
                    isGenerating = false
                    showSuccessAlert = true
                    print("✅ Meal plan generation completed successfully")
                }
            } catch {
                print("❌ Meal plan generation failed: \(error)")
                await MainActor.run {
                    isGenerating = false
                    validationMessage = "Failed to generate meal plan: \(error.localizedDescription)"
                    showValidationError = true
                }
            }
        }
    }

    private func createMealPlanWithAI() async throws {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: duration.days, to: startDate) ?? startDate

        // Get user preferences
        let cuisine = userSettings?.preferredCuisine ?? "Indian Andhra"
        let dietaryPreferences = userSettings?.dietaryPreferences ?? []

        print("🍽️ Generating meals with:")
        print("  - Goal: \(selectedGoal.rawValue)")
        print("  - Duration: \(duration.days) days")
        print("  - Calories: \(calculatedCalories)")
        print("  - Cuisine: \(cuisine)")
        print("  - Provider: \(AIServiceFactory.currentProvider.displayName)")

        // Generate meals using selected AI provider
        let aiService = AIServiceFactory.getService(provider: AIServiceFactory.currentProvider)
        let generatedMeals = try await aiService.generateMealPlan(
            goal: selectedGoal,
            duration: duration.days,
            dailyCalorieTarget: calculatedCalories,
            dailyProteinTarget: calculatedProtein,
            dailyCarbsTarget: calculatedCarbs,
            dailyFatTarget: calculatedFat,
            cuisine: cuisine,
            dietaryPreferences: dietaryPreferences
        )

        print("📋 Generated \(generatedMeals.count) meals")

        // Create meal plan with generated meals
        let mealPlan = MealPlan(
            name: "\(selectedGoal.rawValue) Plan",
            goal: selectedGoal,
            startDate: startDate,
            endDate: endDate,
            dailyCalorieTarget: calculatedCalories,
            dailyProteinTarget: calculatedProtein,
            dailyCarbsTarget: calculatedCarbs,
            dailyFatTarget: calculatedFat,
            meals: [],
            isActive: true
        )

        await MainActor.run {
            // Deactivate other plans
            let descriptor = FetchDescriptor<MealPlan>(predicate: #Predicate { $0.isActive })
            if let existingPlans = try? modelContext.fetch(descriptor) {
                existingPlans.forEach { $0.isActive = false }
            }

            // Insert new plan
            modelContext.insert(mealPlan)

            // Insert generated meals
            for meal in generatedMeals {
                modelContext.insert(meal)
                mealPlan.meals.append(meal)
            }

            try? modelContext.save()
        }
    }
}

// MARK: - Supporting Views

struct GoalOptionView: View {
    let goal: DietGoal
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(goal.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(goal.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.Colors.primary)
                        .font(.title3)
                }
            }
            .padding(Theme.Spacing.md)
            .background(
                isSelected
                    ? Theme.Colors.primary.opacity(0.1)
                    : Theme.Colors.background
            )
            .cornerRadius(Theme.CornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                    .stroke(
                        isSelected ? Theme.Colors.primary : Color.clear,
                        lineWidth: 2
                    )
            )
        }
    }
}

struct ActivityLevelOptionView: View {
    let level: ActivityLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(level.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(level.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.Colors.primary)
                        .font(.title3)
                }
            }
            .padding(Theme.Spacing.md)
            .background(
                isSelected
                    ? Theme.Colors.primary.opacity(0.1)
                    : Theme.Colors.background
            )
            .cornerRadius(Theme.CornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                    .stroke(
                        isSelected ? Theme.Colors.primary : Color.clear,
                        lineWidth: 2
                    )
            )
        }
    }
}

struct NutritionTargetRow: View {
    let icon: String
    let label: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)

            Text(label)
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(unit)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .leading)
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}

// MARK: - Supporting Enums

enum Gender: String, CaseIterable {
    case male = "Male"
    case female = "Female"
}

enum ActivityLevel: String, CaseIterable {
    case sedentary = "Sedentary"
    case light = "Lightly Active"
    case moderate = "Moderately Active"
    case very = "Very Active"
    case extra = "Extremely Active"

    var description: String {
        switch self {
        case .sedentary:
            return "Little or no exercise"
        case .light:
            return "Light exercise 1-3 days/week"
        case .moderate:
            return "Moderate exercise 3-5 days/week"
        case .very:
            return "Hard exercise 6-7 days/week"
        case .extra:
            return "Very hard exercise & physical job"
        }
    }

    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .very: return 1.725
        case .extra: return 1.9
        }
    }
}

enum PlanDuration: CaseIterable {
    case oneWeek
    case twoWeeks
    case fourWeeks

    var displayName: String {
        switch self {
        case .oneWeek: return "1 Week"
        case .twoWeeks: return "2 Weeks"
        case .fourWeeks: return "4 Weeks"
        }
    }

    var days: Int {
        switch self {
        case .oneWeek: return 7
        case .twoWeeks: return 14
        case .fourWeeks: return 28
        }
    }
}

// MARK: - Preview
#Preview {
    MealPlanCreatorView()
        .modelContainer(for: [UserSettings.self, MealPlan.self], inMemory: true)
}
