import Foundation

// MARK: - JSON shape we ask the model to return
private struct AIRecipe: Decodable {
    let name: String
    let ingredients: [String]
    let steps: [String]
    let cookingTime: Int
    let difficulty: String   // "Easy" | "Medium" | "Hard"
}

private struct AIRecipeResponse: Decodable {
    let recipes: [AIRecipe]
}

final class AIRecipeService {
    static let shared = AIRecipeService()
    private init() {}

    // ⚠️ Never hardcode a real key in shipping code. See "Security" note below.
    private let apiKey = "<YOUR_API_KEY>"
    private let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!

    func suggestRecipes(forIngredients ingredients: [String]) async throws -> [Recipe] {
        let prompt = """
        You are a helpful chef. Using primarily these ingredients: \(ingredients.joined(separator: ", ")), \
        suggest 3 recipes. Respond ONLY with JSON in exactly this shape:
        {"recipes":[{"name":"","ingredients":[""],"steps":[""],"cookingTime":0,"difficulty":"Easy"}]}
        difficulty must be one of: Easy, Medium, Hard. cookingTime is minutes.
        """

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [["role": "user", "content": prompt]],
            "response_format": ["type": "json_object"],
            "temperature": 0.7
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        // The chat API wraps content in choices[].message.content (a JSON string).
        let envelope = try JSONDecoder().decode(ChatEnvelope.self, from: data)
        guard let jsonString = envelope.choices.first?.message.content,
              let jsonData = jsonString.data(using: .utf8) else {
            return []
        }

        let decoded = try JSONDecoder().decode(AIRecipeResponse.self, from: jsonData)

        return decoded.recipes.map { ai in
            Recipe(
                name: ai.name,
                ingredients: ai.ingredients,
                steps: ai.steps,
                cookingTime: ai.cookingTime,
                difficulty: RecipeDifficulty(rawValue: ai.difficulty) ?? .easy
            )
        }
    }
}

// Minimal decoding of the chat response wrapper.
private struct ChatEnvelope: Decodable {
    struct Choice: Decodable { let message: Message }
    struct Message: Decodable { let content: String }
    let choices: [Choice]
}
