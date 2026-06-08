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
    }
}

#Preview {
    NavigationStack {
        AISettingsView()
    }
}
