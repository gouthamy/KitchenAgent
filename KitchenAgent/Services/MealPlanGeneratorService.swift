//
//  MealPlanGeneratorService.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import Foundation

class MealPlanGeneratorService {
    static let shared = MealPlanGeneratorService()

    private init() {}

    /// Generate a complete 7-day meal plan using ChatGPT
    /// Uses BATCH GENERATION for reliability (generates 1 day at a time)
    func generateMealPlan(
        goal: DietGoal,
        duration: Int = 7, // days
        dailyCalorieTarget: Int,
        dailyProteinTarget: Double,
        dailyCarbsTarget: Double,
        dailyFatTarget: Double,
        cuisine: String = "Indian Andhra",
        dietaryPreferences: [String] = ["Non-Vegetarian"]
    ) async throws -> [PlannedMeal] {

        // Get API key from UserDefaults
        guard let apiKey = UserDefaults.standard.string(forKey: "chatgpt_api_key"), !apiKey.isEmpty else {
            print("❌ No ChatGPT API key found")
            throw MealPlanError.noAPIKey
        }

        print("🔑 API key found, generating meals in batches...")

        var allMeals: [PlannedMeal] = []

        // Generate meals day by day for reliability
        for day in 1...duration {
            print("📅 Generating day \(day)/\(duration)...")

            let prompt = buildDailyMealPrompt(
                day: day,
                goal: goal,
                dailyCalorieTarget: dailyCalorieTarget,
                dailyProteinTarget: dailyProteinTarget,
                dailyCarbsTarget: dailyCarbsTarget,
                dailyFatTarget: dailyFatTarget,
                cuisine: cuisine,
                dietaryPreferences: dietaryPreferences
            )

            do {
                let response = try await callChatGPT(prompt: prompt, apiKey: apiKey)
                let dayMeals = convertToPlannedMeals(mealPlanResponse: response, dayOffset: day - 1)
                allMeals.append(contentsOf: dayMeals)
                print("✅ Day \(day) complete: \(dayMeals.count) meals generated")

                // Small delay to avoid rate limiting
                if day < duration {
                    try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                }
            } catch {
                print("❌ Failed to generate day \(day): \(error)")
                throw MealPlanError.generationFailed("Failed on day \(day): \(error.localizedDescription)")
            }
        }

        print("🎉 All meals generated: \(allMeals.count) total")
        return allMeals
    }

    /// Build prompt for ONE day of meals (more reliable than all at once)
    private func buildDailyMealPrompt(
        day: Int,
        goal: DietGoal,
        dailyCalorieTarget: Int,
        dailyProteinTarget: Double,
        dailyCarbsTarget: Double,
        dailyFatTarget: Double,
        cuisine: String,
        dietaryPreferences: [String]
    ) -> String {
        // Split daily calories across 5 meals
        let breakfastCals = Int(Double(dailyCalorieTarget) * 0.25) // 25%
        let morningSnackCals = Int(Double(dailyCalorieTarget) * 0.10) // 10%
        let lunchCals = Int(Double(dailyCalorieTarget) * 0.30) // 30%
        let eveningSnackCals = Int(Double(dailyCalorieTarget) * 0.10) // 10%
        let dinnerCals = Int(Double(dailyCalorieTarget) * 0.25) // 25%

        return """
        Generate ONE DAY (Day \(day)) of meals for a \(goal.rawValue) meal plan.

        DAILY TARGETS:
        - Total Calories: \(dailyCalorieTarget) kcal
        - Protein: \(Int(dailyProteinTarget))g
        - Carbs: \(Int(dailyCarbsTarget))g
        - Fat: \(Int(dailyFatTarget))g

        Generate exactly 5 meals for Day \(day):
        1. Breakfast: ~\(breakfastCals) kcal (8:00 AM)
        2. Morning Snack: ~\(morningSnackCals) kcal (11:00 AM)
        3. Lunch: ~\(lunchCals) kcal (1:00 PM)
        4. Evening Snack: ~\(eveningSnackCals) kcal (5:00 PM)
        5. Dinner: ~\(dinnerCals) kcal (8:00 PM)

        CUISINE: \(cuisine)
        DIETARY: \(dietaryPreferences.joined(separator: ", "))

        REQUIREMENTS:
        - All recipes must be authentic \(cuisine) dishes
        - Respect dietary preferences
        - Make snacks simple (under 10 min prep)
        - Include ingredient quantities
        - Provide accurate nutrition data

        Format as JSON array with EXACTLY this structure:
        [
          {
            "day": \(day),
            "mealType": "Breakfast",
            "recipeName": "Upma with Vegetables",
            "ingredients": ["1 cup semolina", "2 tbsp oil", "1 onion chopped", "Mixed vegetables 1 cup", "Mustard seeds 1 tsp", "Curry leaves", "Salt to taste"],
            "instructions": "1. Heat oil in pan\\n2. Add mustard seeds and curry leaves\\n3. Add onions and vegetables\\n4. Add semolina and water\\n5. Cook until done",
            "cookingTime": 20,
            "nutrition": {
              "calories": \(breakfastCals),
              "protein": 12.0,
              "carbs": 45.0,
              "fat": 8.0,
              "fiber": 5.0,
              "sugar": 3.0
            }
          }
        ]

        CRITICAL: Return ONLY valid JSON array with all 5 meals. No markdown, no explanations.
        """
    }

    private func buildMealPlanPrompt(
        goal: DietGoal,
        duration: Int,
        dailyCalorieTarget: Int,
        dailyProteinTarget: Double,
        dailyCarbsTarget: Double,
        dailyFatTarget: Double,
        cuisine: String,
        dietaryPreferences: [String]
    ) -> String {

        // Calculate per-meal calorie targets
        let breakfastCals = Int(Double(dailyCalorieTarget) * 0.25) // 25%
        let lunchCals = Int(Double(dailyCalorieTarget) * 0.30) // 30%
        let dinnerCals = Int(Double(dailyCalorieTarget) * 0.30) // 30%
        let snackCals = Int(Double(dailyCalorieTarget) * 0.075) // 7.5% each snack

        return """
        You are an expert nutritionist and chef specializing in \(cuisine) cuisine. Generate a complete \(duration)-day meal plan for a person with the following goals:

        DIET GOAL: \(goal.rawValue)
        Goal Description: \(goal.description)

        DAILY NUTRITIONAL TARGETS:
        - Total Calories: \(dailyCalorieTarget) kcal
        - Protein: \(Int(dailyProteinTarget))g
        - Carbohydrates: \(Int(dailyCarbsTarget))g
        - Fat: \(Int(dailyFatTarget))g

        MEAL STRUCTURE (5 meals per day):
        1. Breakfast: ~\(breakfastCals) kcal (8:00 AM)
        2. Morning Snack: ~\(snackCals) kcal (11:00 AM)
        3. Lunch: ~\(lunchCals) kcal (1:00 PM)
        4. Evening Snack: ~\(snackCals) kcal (5:00 PM)
        5. Dinner: ~\(dinnerCals) kcal (8:00 PM)

        CUISINE & DIETARY REQUIREMENTS:
        - Cuisine: \(cuisine)
        - Dietary Preferences: \(dietaryPreferences.joined(separator: ", "))

        IMPORTANT GUIDELINES:
        1. All recipes must be authentic \(cuisine) dishes
        2. Use traditional ingredients and cooking methods
        3. Respect dietary preferences: \(dietaryPreferences.joined(separator: ", "))
        4. Ensure variety - no recipe should repeat across the \(duration) days
        5. Balance spice levels and flavors throughout the day
        6. Include seasonal ingredients when possible
        7. Make snacks simple and quick to prepare (under 10 minutes)
        8. Cooking times should be realistic and accurate

        For each meal, provide:
        - Recipe name (authentic \(cuisine) name)
        - Complete ingredient list with quantities
        - Step-by-step cooking instructions (detailed but concise)
        - Accurate nutrition information (calories, protein, carbs, fat, sugar)
        - Cooking time in minutes
        - Brief description or serving suggestions

        Format your response as a JSON array with this exact structure:
        [
          {
            "day": 1,
            "mealType": "Breakfast",
            "recipeName": "Authentic Recipe Name",
            "ingredients": [
              "2 cups rice flour",
              "1 tsp cumin seeds",
              "Salt to taste"
            ],
            "instructions": [
              "Step 1: Detailed instruction",
              "Step 2: Detailed instruction",
              "Step 3: Detailed instruction"
            ],
            "nutrition": {
              "calories": 450,
              "protein": 12.5,
              "carbs": 65.0,
              "fat": 15.0,
              "fiber": 4.5,
              "sugar": 3.0
            },
            "cookingTime": 30,
            "description": "Brief description or serving tip"
          }
        ]

        CRITICAL REQUIREMENTS:
        - Generate exactly \(duration * 5) meals (\(duration) days × 5 meals/day)
        - Each day must have: Breakfast, Morning Snack, Lunch, Evening Snack, Dinner
        - Daily totals should approximately match the calorie and macro targets
        - All recipes must be authentic \(cuisine) dishes
        - Return ONLY valid JSON, no additional text or markdown
        - Ensure nutrition values are realistic and accurate
        - Include fiber and sugar values for all meals

        Generate the complete \(duration)-day meal plan now.
        """
    }

    private func callChatGPT(prompt: String, apiKey: String) async throws -> MealPlanResponse {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw MealPlanError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 180 // 3 minutes - generating 35 meals takes time!

        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "system",
                    "content": "You are an expert nutritionist and chef. Generate detailed, authentic meal plans with accurate nutritional information. Always respond with valid JSON only."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": 0.7,
            "max_tokens": 2500 // Enough for 5 meals per day
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MealPlanError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("ChatGPT API Error: \(errorMessage)")
            throw MealPlanError.apiError(httpResponse.statusCode, errorMessage)
        }

        // Parse ChatGPT response
        let chatGPTResponse = try JSONDecoder().decode(ChatGPTResponse.self, from: data)

        guard let content = chatGPTResponse.choices.first?.message.content else {
            throw MealPlanError.noContent
        }

        // Extract JSON from response
        let jsonString = extractJSON(from: content)

        print("📝 Raw JSON response (first 500 chars):")
        print(String(jsonString.prefix(500)))

        guard let jsonData = jsonString.data(using: .utf8) else {
            print("❌ Failed to convert JSON string to data")
            throw MealPlanError.invalidJSON
        }

        do {
            let mealPlanData = try JSONDecoder().decode([MealPlanDayData].self, from: jsonData)
            print("✅ Successfully decoded \(mealPlanData.count) meals")
            return MealPlanResponse(meals: mealPlanData)
        } catch {
            print("❌ JSON Decoding Error: \(error)")
            print("📄 Full JSON for debugging:")
            print(jsonString)
            throw error
        }
    }

    private func extractJSON(from text: String) -> String {
        // Remove markdown code blocks if present
        var cleanText = text
        if let startRange = cleanText.range(of: "```json") {
            cleanText.removeSubrange(cleanText.startIndex..<startRange.upperBound)
        }
        if let endRange = cleanText.range(of: "```", options: .backwards) {
            cleanText.removeSubrange(endRange.lowerBound..<cleanText.endIndex)
        }

        // Try to find JSON array in the response
        if let startIndex = cleanText.firstIndex(of: "["),
           let endIndex = cleanText.lastIndex(of: "]") {
            return String(cleanText[startIndex...endIndex])
        }
        return cleanText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func convertToPlannedMeals(mealPlanResponse: MealPlanResponse, dayOffset: Int = 0) -> [PlannedMeal] {
        var plannedMeals: [PlannedMeal] = []
        let calendar = Calendar.current
        let today = Date()

        for mealData in mealPlanResponse.meals {
            // Calculate the date for this meal (use dayOffset for batch generation)
            let actualDay = dayOffset > 0 ? dayOffset : (mealData.day - 1)
            guard let mealDate = calendar.date(byAdding: .day, value: actualDay, to: today) else {
                continue
            }

            // Map meal type string to MealType enum
            guard let mealType = mapMealType(from: mealData.mealType) else {
                print("Warning: Unknown meal type: \(mealData.mealType)")
                continue
            }

            // Set the time based on meal type
            let (hour, minute) = mealType.defaultTime
            guard let scheduledDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: mealDate) else {
                continue
            }

            // Convert nutrition data
            let nutritionData = NutritionData(
                calories: mealData.nutrition.calories,
                protein: mealData.nutrition.protein,
                carbs: mealData.nutrition.carbs,
                fat: mealData.nutrition.fat,
                fiber: mealData.nutrition.fiber,
                sugar: mealData.nutrition.sugar
            )

            // Create instructions string
            let instructionsText = mealData.instructions.enumerated().map { index, instruction in
                "Step \(index + 1): \(instruction)"
            }.joined(separator: "\n\n")

            // Create PlannedMeal
            let plannedMeal = PlannedMeal(
                date: scheduledDate,
                mealType: mealType,
                recipeName: mealData.recipeName,
                recipeInstructions: instructionsText,
                ingredients: mealData.ingredients,
                nutrition: nutritionData,
                cookingTime: mealData.cookingTime,
                prepTime: calculatePrepTime(cookingTime: mealData.cookingTime, mealType: mealType)
            )

            plannedMeals.append(plannedMeal)
        }

        return plannedMeals.sorted { $0.date < $1.date }
    }

    private func mapMealType(from string: String) -> MealType? {
        switch string.lowercased() {
        case "breakfast":
            return .breakfast
        case "morning snack", "morningsnack":
            return .morningSnack
        case "lunch":
            return .lunch
        case "evening snack", "eveningsnack":
            return .eveningSnack
        case "dinner":
            return .dinner
        default:
            return nil
        }
    }

    private func calculatePrepTime(cookingTime: Int, mealType: MealType) -> Int {
        // Snacks should have shorter prep time
        switch mealType {
        case .morningSnack, .eveningSnack:
            return 10
        case .breakfast:
            return min(30, cookingTime + 10)
        case .lunch, .dinner:
            return min(45, cookingTime + 15)
        }
    }
}

// MARK: - Models

struct MealPlanResponse: Codable {
    let meals: [MealPlanDayData]
}

struct MealPlanDayData: Codable {
    let day: Int
    let mealType: String
    let recipeName: String
    let ingredients: [String]
    let instructions: [String]
    let nutrition: NutritionDataCodable
    let cookingTime: Int
    let description: String?

    // Custom decoding to handle both string and array formats
    enum CodingKeys: String, CodingKey {
        case day, mealType, recipeName, ingredients, instructions, nutrition, cookingTime, description
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        day = try container.decode(Int.self, forKey: .day)
        mealType = try container.decode(String.self, forKey: .mealType)
        recipeName = try container.decode(String.self, forKey: .recipeName)
        nutrition = try container.decode(NutritionDataCodable.self, forKey: .nutrition)
        cookingTime = try container.decode(Int.self, forKey: .cookingTime)
        description = try? container.decode(String.self, forKey: .description)

        // Flexible ingredients parsing (array or string)
        if let ingredientsArray = try? container.decode([String].self, forKey: .ingredients) {
            ingredients = ingredientsArray
        } else if let ingredientsString = try? container.decode(String.self, forKey: .ingredients) {
            ingredients = ingredientsString
                .split(separator: "\n")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        } else {
            ingredients = []
        }

        // Flexible instructions parsing (array or string)
        if let instructionsArray = try? container.decode([String].self, forKey: .instructions) {
            instructions = instructionsArray
        } else if let instructionsString = try? container.decode(String.self, forKey: .instructions) {
            // Split by newlines and clean up
            instructions = instructionsString
                .split(separator: "\n")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        } else {
            instructions = ["No instructions provided"]
        }
    }

    // Standard encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(day, forKey: .day)
        try container.encode(mealType, forKey: .mealType)
        try container.encode(recipeName, forKey: .recipeName)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encode(instructions, forKey: .instructions)
        try container.encode(nutrition, forKey: .nutrition)
        try container.encode(cookingTime, forKey: .cookingTime)
        try container.encodeIfPresent(description, forKey: .description)
    }
}

struct NutritionDataCodable: Codable {
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double
}

enum MealPlanError: LocalizedError {
    case noAPIKey
    case invalidURL
    case invalidResponse
    case apiError(Int, String)
    case noContent
    case invalidJSON
    case invalidMealData
    case generationFailed(String)

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "ChatGPT API key not configured. Go to Settings → ChatGPT API to add your key."
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let code, let message):
            return "API Error (\(code)): \(message)"
        case .noContent:
            return "No content in response"
        case .invalidJSON:
            return "Invalid JSON format in response. Please try again."
        case .invalidMealData:
            return "Invalid meal data received from API"
        case .generationFailed(let message):
            return "Generation failed: \(message)"
        }
    }
}
