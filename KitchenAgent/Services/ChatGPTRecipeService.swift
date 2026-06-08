//
//  ChatGPTRecipeService.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import Foundation

class ChatGPTRecipeService {
    static let shared = ChatGPTRecipeService()

    private init() {}

    /// Generate recipe suggestions using ChatGPT
    func generateRecipeSuggestions(
        ingredients: [String],
        cuisine: String = "Indian Andhra",
        dietaryPreferences: [String] = [],
        expiringItems: [String] = []
    ) async throws -> [AIRecipeSuggestion] {

        // Get API key from UserDefaults
        guard let apiKey = UserDefaults.standard.string(forKey: "chatgpt_api_key"), !apiKey.isEmpty else {
            throw RecipeError.noAPIKey
        }

        // Build the prompt
        let prompt = buildPrompt(
            ingredients: ingredients,
            cuisine: cuisine,
            dietaryPreferences: dietaryPreferences,
            expiringItems: expiringItems
        )

        // Call ChatGPT API
        let recipes = try await callChatGPT(prompt: prompt, apiKey: apiKey)
        return recipes
    }

    private func buildPrompt(
        ingredients: [String],
        cuisine: String,
        dietaryPreferences: [String],
        expiringItems: [String]
    ) -> String {
        var prompt = """
        You are a helpful cooking assistant. Generate 5 recipe suggestions based on the following:

        Available Ingredients: \(ingredients.joined(separator: ", "))

        Preferred Cuisine: \(cuisine)

        """

        if !dietaryPreferences.isEmpty {
            prompt += "Dietary Preferences: \(dietaryPreferences.joined(separator: ", "))\n\n"
        }

        if !expiringItems.isEmpty {
            prompt += "Priority: Use these ingredients first (expiring soon): \(expiringItems.joined(separator: ", "))\n\n"
        }

        prompt += """

        For each recipe, provide:
        1. Recipe name (authentic to \(cuisine) cuisine)
        2. Cooking time in minutes (realistic time)
        3. Difficulty level (Easy/Medium/Hard)
        4. List of required ingredients (use available ingredients as much as possible)
        5. Brief cooking instructions (3-5 steps)

        Format your response as JSON array with this structure:
        [
          {
            "name": "Recipe Name",
            "cookingTime": 30,
            "difficulty": "Easy",
            "ingredients": ["ingredient1", "ingredient2"],
            "instructions": ["Step 1", "Step 2", "Step 3"],
            "matchingIngredientsCount": 5
          }
        ]

        IMPORTANT:
        - Prioritize recipes that use expiring ingredients
        - Make recipes authentic to \(cuisine) cuisine
        - Respect dietary preferences: \(dietaryPreferences.joined(separator: ", "))
        - Return ONLY valid JSON, no additional text
        """

        return prompt
    }

    private func callChatGPT(prompt: String, apiKey: String) async throws -> [AIRecipeSuggestion] {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw RecipeError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a helpful cooking assistant specialized in \(UserDefaults.standard.string(forKey: "preferred_cuisine") ?? "Indian Andhra") cuisine."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 2000
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RecipeError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("ChatGPT API Error: \(errorMessage)")
            throw RecipeError.apiError(httpResponse.statusCode, errorMessage)
        }

        // Parse ChatGPT response
        let chatGPTResponse = try JSONDecoder().decode(ChatGPTResponse.self, from: data)

        guard let content = chatGPTResponse.choices.first?.message.content else {
            throw RecipeError.noContent
        }

        // Extract JSON from response
        let jsonString = extractJSON(from: content)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw RecipeError.invalidJSON
        }

        let recipes = try JSONDecoder().decode([AIRecipeSuggestion].self, from: jsonData)
        return recipes
    }

    private func extractJSON(from text: String) -> String {
        // Try to find JSON array in the response
        if let startIndex = text.firstIndex(of: "["),
           let endIndex = text.lastIndex(of: "]") {
            return String(text[startIndex...endIndex])
        }
        return text
    }
}

// MARK: - Models

struct AIRecipeSuggestion: Codable, Identifiable {
    var id = UUID()
    let name: String
    let cookingTime: Int
    let difficulty: String
    let ingredients: [String]
    let instructions: [String]
    let matchingIngredientsCount: Int

    enum CodingKeys: String, CodingKey {
        case name, cookingTime, difficulty, ingredients, instructions, matchingIngredientsCount
    }
}

struct ChatGPTResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message
    }

    struct Message: Codable {
        let content: String
    }
}

enum RecipeError: LocalizedError {
    case noAPIKey
    case invalidURL
    case invalidResponse
    case apiError(Int, String)
    case noContent
    case invalidJSON

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
            return "Invalid JSON format in response"
        }
    }
}
