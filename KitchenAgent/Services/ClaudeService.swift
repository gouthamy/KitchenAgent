//
//  ClaudeService.swift
//  KitchenAgent
//
//  Anthropic Claude Implementation
//

import Foundation
import UIKit

class ClaudeService: AIService {
    static let shared = ClaudeService()
    private init() {}

    nonisolated func generateMealPlan(
        goal: DietGoal,
        duration: Int,
        dailyCalorieTarget: Int,
        dailyProteinTarget: Double,
        dailyCarbsTarget: Double,
        dailyFatTarget: Double,
        cuisine: String,
        dietaryPreferences: [String]
    ) async throws -> [PlannedMeal] {
        guard let apiKey = UserDefaults.standard.string(forKey: "claude_api_key"), !apiKey.isEmpty else {
            throw AIError.noAPIKey("Claude API key not configured")
        }

        print("🔑 Claude API key found, generating meals in batches...")

        var allMeals: [PlannedMeal] = []

        for day in 1...duration {
            print("📅 Generating day \(day)/\(duration) with Claude...")

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
                let response = try await callClaude(prompt: prompt, apiKey: apiKey)
                let dayMeals = convertToPlannedMeals(response: response, dayOffset: day - 1)
                allMeals.append(contentsOf: dayMeals)
                print("✅ Day \(day) complete: \(dayMeals.count) meals generated")

                if day < duration {
                    try await Task.sleep(nanoseconds: 500_000_000)
                }
            } catch {
                print("❌ Failed to generate day \(day): \(error)")
                throw AIError.generationFailed("Failed on day \(day): \(error.localizedDescription)")
            }
        }

        print("🎉 Claude generated all meals: \(allMeals.count) total")
        return allMeals
    }

    nonisolated func analyzeFoodImage(_ image: UIImage) async throws -> FoodNutrition {
        guard let apiKey = UserDefaults.standard.string(forKey: "claude_api_key"), !apiKey.isEmpty else {
            throw AIError.noAPIKey("Claude API key not configured")
        }

        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw AIError.invalidImage
        }

        let base64Image = imageData.base64EncodedString()
        return try await callClaudeVision(base64Image: base64Image, apiKey: apiKey)
    }

    // MARK: - Private Methods

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
        let breakfastCals = Int(Double(dailyCalorieTarget) * 0.25)
        let morningSnackCals = Int(Double(dailyCalorieTarget) * 0.10)
        let lunchCals = Int(Double(dailyCalorieTarget) * 0.30)
        let eveningSnackCals = Int(Double(dailyCalorieTarget) * 0.10)
        let dinnerCals = Int(Double(dailyCalorieTarget) * 0.25)

        return """
        Generate ONE DAY (Day \(day)) of meals for a \(goal.rawValue) meal plan.

        DAILY TARGETS:
        - Calories: \(dailyCalorieTarget) kcal
        - Protein: \(Int(dailyProteinTarget))g
        - Carbs: \(Int(dailyCarbsTarget))g
        - Fat: \(Int(dailyFatTarget))g

        Generate exactly 5 meals:
        1. Breakfast (~\(breakfastCals) kcal)
        2. Morning Snack (~\(morningSnackCals) kcal)
        3. Lunch (~\(lunchCals) kcal)
        4. Evening Snack (~\(eveningSnackCals) kcal)
        5. Dinner (~\(dinnerCals) kcal)

        Cuisine: \(cuisine)
        Dietary: \(dietaryPreferences.joined(separator: ", "))

        Return JSON array with this structure:
        [
          {
            "day": \(day),
            "mealType": "Breakfast",
            "recipeName": "Upma",
            "ingredients": ["1 cup semolina", "2 tbsp oil"],
            "instructions": "1. Heat oil\\n2. Add semolina",
            "cookingTime": 20,
            "nutrition": {"calories": \(breakfastCals), "protein": 12.0, "carbs": 45.0, "fat": 8.0, "fiber": 5.0, "sugar": 3.0}
          }
        ]

        Return ONLY valid JSON, no markdown.
        """
    }

    private func callClaude(prompt: String, apiKey: String) async throws -> MealPlanResponse {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw AIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = 180

        let requestBody: [String: Any] = [
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 2500,
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("Claude API Error: \(errorMessage)")
            throw AIError.apiError(httpResponse.statusCode, errorMessage)
        }

        // Parse Claude response
        let claudeResponse = try JSONDecoder().decode(ClaudeResponse.self, from: data)
        guard let content = claudeResponse.content.first?.text else {
            throw AIError.noContent
        }

        // Extract JSON from response
        let jsonString = extractJSON(from: content)
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw AIError.invalidJSON
        }

        let decoder = JSONDecoder()
        let mealResponse = try decoder.decode(MealPlanResponse.self, from: jsonData)
        return mealResponse
    }

    private func callClaudeVision(base64Image: String, apiKey: String) async throws -> FoodNutrition {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw AIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = 60

        let prompt = """
        Analyze this food image and provide nutrition information.

        Identify: food name, serving size, calories, protein (g), carbs (g), fat (g).

        Respond ONLY with JSON:
        {
          "foodName": "Food name",
          "servingSize": "1 plate",
          "calories": 500,
          "protein": 25.0,
          "carbs": 60.0,
          "fat": 15.0
        }
        """

        let requestBody: [String: Any] = [
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 500,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ],
                        [
                            "type": "text",
                            "text": prompt
                        ]
                    ]
                ]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AIError.invalidResponse
        }

        let claudeResponse = try JSONDecoder().decode(ClaudeResponse.self, from: data)
        guard let content = claudeResponse.content.first?.text else {
            throw AIError.noContent
        }

        let jsonString = extractJSON(from: content)
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw AIError.invalidJSON
        }

        let nutritionResponse = try JSONDecoder().decode(FoodNutritionResponse.self, from: jsonData)

        return FoodNutrition(
            foodName: nutritionResponse.foodName,
            calories: nutritionResponse.calories,
            protein: nutritionResponse.protein,
            carbs: nutritionResponse.carbs,
            fat: nutritionResponse.fat,
            servingSize: nutritionResponse.servingSize
        )
    }

    private func convertToPlannedMeals(response: MealPlanResponse, dayOffset: Int) -> [PlannedMeal] {
        var meals: [PlannedMeal] = []
        let calendar = Calendar.current
        let today = Date()

        for mealData in response.meals {
            guard let mealDate = calendar.date(byAdding: .day, value: dayOffset, to: today),
                  let mealType = mapMealType(from: mealData.mealType) else {
                continue
            }

            let (hour, minute) = mealType.defaultTime
            guard let scheduledDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: mealDate) else {
                continue
            }

            let nutrition = NutritionData(
                calories: mealData.nutrition.calories,
                protein: mealData.nutrition.protein,
                carbs: mealData.nutrition.carbs,
                fat: mealData.nutrition.fat,
                fiber: mealData.nutrition.fiber,
                sugar: mealData.nutrition.sugar
            )

            let instructions = mealData.instructions.enumerated().map { index, instruction in
                "Step \(index + 1): \(instruction)"
            }.joined(separator: "\n\n")

            let meal = PlannedMeal(
                date: scheduledDate,
                mealType: mealType,
                recipeName: mealData.recipeName,
                recipeInstructions: instructions,
                ingredients: mealData.ingredients,
                nutrition: nutrition,
                cookingTime: mealData.cookingTime,
                prepTime: 30
            )

            meals.append(meal)
        }

        return meals
    }

    private func mapMealType(from string: String) -> MealType? {
        let normalized = string.lowercased()
        switch normalized {
        case "breakfast": return .breakfast
        case "morning snack", "morningsnack": return .morningSnack
        case "lunch": return .lunch
        case "evening snack", "eveningsnack": return .eveningSnack
        case "dinner": return .dinner
        default: return nil
        }
    }

    private func extractJSON(from text: String) -> String {
        if let startIndex = text.firstIndex(of: "["),
           let endIndex = text.lastIndex(of: "]") {
            return String(text[startIndex...endIndex])
        }
        if let startIndex = text.firstIndex(of: "{"),
           let endIndex = text.lastIndex(of: "}") {
            return String(text[startIndex...endIndex])
        }
        return text
    }
}

// MARK: - Claude Response Models

struct ClaudeResponse: Codable {
    let content: [ClaudeContent]
}

struct ClaudeContent: Codable {
    let text: String
    let type: String
}

// MARK: - Error Types

enum AIError: LocalizedError {
    case noAPIKey(String)
    case invalidURL
    case invalidResponse
    case invalidImage
    case apiError(Int, String)
    case noContent
    case invalidJSON
    case generationFailed(String)

    var errorDescription: String? {
        switch self {
        case .noAPIKey(let message): return message
        case .invalidURL: return "Invalid API URL"
        case .invalidResponse: return "Invalid response from server"
        case .invalidImage: return "Invalid image format"
        case .apiError(let code, let message): return "API Error (\(code)): \(message)"
        case .noContent: return "No content in response"
        case .invalidJSON: return "Invalid JSON format"
        case .generationFailed(let message): return message
        }
    }
}
