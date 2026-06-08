//
//  AISettingsView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI

struct AISettingsView: View {
    @AppStorage("chatgpt_api_key") private var apiKey: String = ""
    @State private var showingAPIKey = false
    @State private var tempAPIKey = ""
    @State private var showingSaved = false
    @State private var isTesting = false
    @State private var testResult: TestResult? = nil

    enum TestResult {
        case success
        case failure(String)
    }

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.title)
                            .foregroundColor(.green)
                        VStack(alignment: .leading) {
                            Text("ChatGPT Integration")
                                .font(.headline)
                            Text("Optional Feature")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Text("Add your OpenAI API key to enable:")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    VStack(alignment: .leading, spacing: 4) {
                        Label("AI-powered recipe suggestions", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Label("Smart food recognition", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Label("Personalized cooking tips", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .padding(.vertical, 8)
            }

            Section("API Key Configuration") {
                HStack {
                    if showingAPIKey {
                        TextField("sk-...", text: $tempAPIKey)
                            .foregroundColor(.primary)
                            .textContentType(.password)
                    } else {
                        Text(apiKey.isEmpty ? "Not configured" : "••••••••••••••••")
                            .foregroundColor(apiKey.isEmpty ? .secondary : .green)
                    }

                    Button {
                        showingAPIKey.toggle()
                        if showingAPIKey {
                            tempAPIKey = apiKey
                        }
                    } label: {
                        Image(systemName: showingAPIKey ? "eye.slash" : "eye")
                            .foregroundColor(.secondary)
                    }
                }

                if showingAPIKey {
                    Button {
                        saveAPIKey()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Save API Key")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(tempAPIKey.isEmpty)
                }

                if showingSaved {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("API Key Saved!")
                            .foregroundColor(.green)
                    }
                }
            }

            Section("How to Get API Key") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("1. Visit OpenAI Platform")
                        .font(.subheadline)
                    Link("https://platform.openai.com/api-keys", destination: URL(string: "https://platform.openai.com/api-keys")!)
                        .font(.caption)
                        .foregroundColor(.blue)

                    Text("2. Sign in or create account")
                        .font(.subheadline)

                    Text("3. Create new API key")
                        .font(.subheadline)

                    Text("4. Copy and paste here")
                        .font(.subheadline)
                }
                .padding(.vertical, 4)
            }

            Section("Privacy & Security") {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Your API key is stored securely on your device", systemImage: "lock.shield")
                        .font(.caption)
                        .foregroundColor(.green)

                    Label("We never store your API key on our servers", systemImage: "checkmark.shield")
                        .font(.caption)
                        .foregroundColor(.green)

                    Label("API calls go directly to OpenAI", systemImage: "arrow.right.circle")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .padding(.vertical, 4)
            }

            if !apiKey.isEmpty {
                Section("Test API Key") {
                    Button {
                        testAPIKey()
                    } label: {
                        HStack {
                            Spacer()
                            if isTesting {
                                ProgressView()
                                    .padding(.trailing, 8)
                                Text("Testing...")
                            } else {
                                Image(systemName: "play.circle")
                                Text("Test Connection")
                            }
                            Spacer()
                        }
                    }
                    .disabled(isTesting)

                    if let result = testResult {
                        switch result {
                        case .success:
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("API Key is Valid!")
                                    .foregroundColor(.green)
                            }
                        case .failure(let error):
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text("Test Failed")
                                        .foregroundColor(.red)
                                }
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        removeAPIKey()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Remove API Key")
                            Spacer()
                        }
                    }
                }
            }
        }
        .navigationTitle("AI Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func saveAPIKey() {
        apiKey = tempAPIKey
        showingAPIKey = false
        showingSaved = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingSaved = false
        }
    }

    private func removeAPIKey() {
        apiKey = ""
        tempAPIKey = ""
        showingAPIKey = false
        testResult = nil
    }

    private func testAPIKey() {
        isTesting = true
        testResult = nil

        Task {
            do {
                let isValid = try await validateAPIKey(apiKey)
                await MainActor.run {
                    isTesting = false
                    testResult = isValid ? .success : .failure("Invalid API key")
                }
            } catch {
                await MainActor.run {
                    isTesting = false
                    testResult = .failure(error.localizedDescription)
                }
            }
        }
    }

    private func validateAPIKey(_ key: String) async throws -> Bool {
        guard !key.isEmpty else {
            throw NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "API key is empty"])
        }

        // OpenAI API test endpoint
        guard let url = URL(string: "https://api.openai.com/v1/models") else {
            throw NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }

        if httpResponse.statusCode == 200 {
            return true
        } else if httpResponse.statusCode == 401 {
            throw NSError(domain: "APIError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid API key - Unauthorized"])
        } else if httpResponse.statusCode == 429 {
            throw NSError(domain: "APIError", code: 429, userInfo: [NSLocalizedDescriptionKey: "Rate limit exceeded - Try again later"])
        } else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Error \(httpResponse.statusCode): \(errorMessage)"])
        }
    }
}

#Preview {
    NavigationStack {
        AISettingsView()
    }
}
