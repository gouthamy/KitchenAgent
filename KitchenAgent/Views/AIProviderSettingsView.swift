//
//  AIProviderSettingsView.swift
//  KitchenAgent
//
//  AI Provider Selection & Configuration
//

import SwiftUI

struct AIProviderSettingsView: View {
    @State private var selectedProvider: AIProvider = AIServiceFactory.currentProvider
    @State private var openAIKey: String = UserDefaults.standard.string(forKey: "chatgpt_api_key") ?? ""
    @State private var claudeKey: String = UserDefaults.standard.string(forKey: "claude_api_key") ?? ""
    @State private var showingTestResult = false
    @State private var testResult: String = ""
    @State private var isTesting = false

    var body: some View {
        Form {
            // Provider Selection
            Section {
                Picker("AI Provider", selection: $selectedProvider) {
                    ForEach(AIProvider.allCases, id: \.self) { provider in
                        Label(provider.displayName, systemImage: provider.icon)
                            .tag(provider)
                    }
                }
                .pickerStyle(.inline)
                .onChange(of: selectedProvider) { _, newValue in
                    AIServiceFactory.currentProvider = newValue
                }

                Text(selectedProvider.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("Choose AI Provider")
            }

            // OpenAI Configuration
            Section {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    TextField("API Key", text: $openAIKey)
                        .textContentType(.password)
                        .foregroundColor(.primary)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .onChange(of: openAIKey) { _, newValue in
                            UserDefaults.standard.set(newValue, forKey: "chatgpt_api_key")
                        }

                    if !openAIKey.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("API Key configured")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }

                    Button {
                        testOpenAI()
                    } label: {
                        HStack {
                            if isTesting && selectedProvider == .openai {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Image(systemName: "checkmark.circle")
                            Text("Test Connection")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(Theme.Colors.primary.opacity(0.1))
                        .foregroundColor(Theme.Colors.primary)
                        .cornerRadius(Theme.CornerRadius.sm)
                    }
                    .disabled(openAIKey.isEmpty || isTesting)

                    instructionsSection(provider: .openai)
                }
            } header: {
                HStack {
                    Image(systemName: "brain.head.profile")
                    Text("OpenAI (ChatGPT)")
                }
            }

            // Claude Configuration
            Section {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    TextField("API Key", text: $claudeKey)
                        .textContentType(.password)
                        .foregroundColor(.primary)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .onChange(of: claudeKey) { _, newValue in
                            UserDefaults.standard.set(newValue, forKey: "claude_api_key")
                        }

                    if !claudeKey.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("API Key configured")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }

                    Button {
                        testClaude()
                    } label: {
                        HStack {
                            if isTesting && selectedProvider == .claude {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Image(systemName: "checkmark.circle")
                            Text("Test Connection")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(Theme.Colors.primary.opacity(0.1))
                        .foregroundColor(Theme.Colors.primary)
                        .cornerRadius(Theme.CornerRadius.sm)
                    }
                    .disabled(claudeKey.isEmpty || isTesting)

                    instructionsSection(provider: .claude)
                }
            } header: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Anthropic Claude")
                }
            }

            // Comparison
            Section {
                comparisonView
            } header: {
                Text("Provider Comparison")
            }
        }
        .navigationTitle("AI Provider")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isTesting ? "Testing..." : "Test Result", isPresented: $showingTestResult) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(testResult)
        }
    }

    private func instructionsSection(provider: AIProvider) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("How to get API key:")
                .font(.caption)
                .fontWeight(.semibold)

            switch provider {
            case .openai:
                Link("1. Visit platform.openai.com/api-keys", destination: URL(string: "https://platform.openai.com/api-keys")!)
                    .font(.caption)
                Text("2. Sign in or create account")
                    .font(.caption)
                Text("3. Create new API key")
                    .font(.caption)
                Text("4. Copy and paste above")
                    .font(.caption)
            case .claude:
                Link("1. Visit console.anthropic.com", destination: URL(string: "https://console.anthropic.com")!)
                    .font(.caption)
                Text("2. Sign in or create account")
                    .font(.caption)
                Text("3. Go to API Keys section")
                    .font(.caption)
                Text("4. Create new key and paste above")
                    .font(.caption)
            }
        }
        .padding(Theme.Spacing.sm)
        .background(Theme.Colors.background)
        .cornerRadius(Theme.CornerRadius.sm)
    }

    private var comparisonView: some View {
        VStack(spacing: Theme.Spacing.md) {
            comparisonRow(
                feature: "Speed",
                openai: "⚡⚡⚡ Fast",
                claude: "⚡⚡ Moderate"
            )
            comparisonRow(
                feature: "Quality",
                openai: "⭐⭐⭐⭐ Good",
                claude: "⭐⭐⭐⭐⭐ Excellent"
            )
            comparisonRow(
                feature: "Cost",
                openai: "💰 $0.15/1M tokens",
                claude: "💰💰 $3/1M tokens"
            )
            comparisonRow(
                feature: "Context",
                openai: "128K tokens",
                claude: "200K tokens"
            )
        }
    }

    private func comparisonRow(feature: String, openai: String, claude: String) -> some View {
        HStack {
            Text(feature)
                .font(.caption)
                .fontWeight(.semibold)
                .frame(width: 70, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text("GPT-4")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(openai)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text("Claude")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(claude)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func testOpenAI() {
        isTesting = true
        Task {
            do {
                // Test OpenAI connection
                try await ChatGPTRecipeService.shared.testConnection()
                await MainActor.run {
                    testResult = "✅ OpenAI connection successful!"
                    isTesting = false
                    showingTestResult = true
                }
            } catch {
                await MainActor.run {
                    testResult = "❌ Failed: \(error.localizedDescription)"
                    isTesting = false
                    showingTestResult = true
                }
            }
        }
    }

    private func testClaude() {
        isTesting = true
        Task {
            do {
                // Simple test - try to get a response
                guard let apiKey = UserDefaults.standard.string(forKey: "claude_api_key"), !apiKey.isEmpty else {
                    throw AIError.noAPIKey("Claude API key not found")
                }

                // Test with simple request
                var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
                request.httpMethod = "POST"
                request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

                let testBody: [String: Any] = [
                    "model": "claude-3-5-sonnet-20241022",
                    "max_tokens": 10,
                    "messages": [["role": "user", "content": "Hi"]]
                ]

                request.httpBody = try JSONSerialization.data(withJSONObject: testBody)

                let (_, response) = try await URLSession.shared.data(for: request)

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    await MainActor.run {
                        testResult = "✅ Claude connection successful!"
                        isTesting = false
                        showingTestResult = true
                    }
                } else {
                    throw AIError.invalidResponse
                }
            } catch {
                await MainActor.run {
                    testResult = "❌ Failed: \(error.localizedDescription)"
                    isTesting = false
                    showingTestResult = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AIProviderSettingsView()
    }
}
