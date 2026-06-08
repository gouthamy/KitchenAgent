//
//  RecipePreferencesView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import SwiftData

struct RecipePreferencesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [UserSettings]

    private var userSettings: UserSettings {
        if let existing = settings.first {
            return existing
        }
        let newSettings = UserSettings()
        modelContext.insert(newSettings)
        try? modelContext.save()
        return newSettings
    }

    // Available cuisines
    private let cuisines = [
        "Indian Andhra",
        "Indian North",
        "Indian South",
        "Chinese",
        "Italian",
        "Mexican",
        "Thai",
        "Japanese",
        "Mediterranean",
        "American",
        "Middle Eastern",
        "Continental"
    ]

    // Dietary preferences
    private let dietaryOptions = [
        "Vegetarian",
        "Non-Vegetarian",
        "Vegan",
        "Gluten-Free",
        "Dairy-Free"
    ]

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.title)
                            .foregroundColor(.green)
                        VStack(alignment: .leading) {
                            Text("Recipe Preferences")
                                .font(.headline)
                            Text("Customize your recipe suggestions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            Section("Preferred Cuisine") {
                Picker("Cuisine Type", selection: Binding(
                    get: { userSettings.preferredCuisine },
                    set: { newValue in
                        userSettings.preferredCuisine = newValue
                        try? modelContext.save()
                    }
                )) {
                    ForEach(cuisines, id: \.self) { cuisine in
                        Text(cuisine).tag(cuisine)
                    }
                }
                .pickerStyle(.menu)

                Text("ChatGPT will suggest recipes from your preferred cuisine")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }

            Section("Dietary Preferences") {
                ForEach(dietaryOptions, id: \.self) { option in
                    Toggle(option, isOn: Binding(
                        get: { userSettings.dietaryPreferences.contains(option) },
                        set: { isOn in
                            if isOn {
                                if !userSettings.dietaryPreferences.contains(option) {
                                    userSettings.dietaryPreferences.append(option)
                                }
                            } else {
                                userSettings.dietaryPreferences.removeAll { $0 == option }
                            }
                            try? modelContext.save()
                        }
                    ))
                }

                Text("ChatGPT will filter recipes based on your dietary preferences")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }

            Section("AI Recipe Suggestions") {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Powered by ChatGPT", systemImage: "sparkles")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)

                    Text("When you add ingredients to your inventory, ChatGPT will suggest personalized recipes based on:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 6) {
                        Label("Your preferred cuisine (\(userSettings.preferredCuisine))", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)

                        if !userSettings.dietaryPreferences.isEmpty {
                            Label("Your dietary preferences", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }

                        Label("Available ingredients in your fridge", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)

                        Label("Items expiring soon", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding(.leading, 8)
                }
                .padding(.vertical, 4)
            }

            Section("Current Settings") {
                HStack {
                    Text("Cuisine")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(userSettings.preferredCuisine)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }

                if !userSettings.dietaryPreferences.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dietary Preferences")
                            .foregroundColor(.secondary)

                        FlowLayout(spacing: 8) {
                            ForEach(userSettings.dietaryPreferences, id: \.self) { pref in
                                Text(pref)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Recipe Preferences")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    NavigationStack {
        RecipePreferencesView()
            .modelContainer(for: UserSettings.self, inMemory: true)
    }
}
