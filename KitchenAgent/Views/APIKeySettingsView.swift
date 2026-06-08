import SwiftUI

struct APIKeySettingsView: View {
    @State private var apiKey: String = KeychainStore.loadAPIKey() ?? ""
    @State private var savedConfirmation = false

    var body: some View {
        Form {
            Section(header: Text("OpenAI API Key"),
                    footer: Text("Your key is stored securely in the Keychain on this device and is only sent to OpenAI. Get a key at platform.openai.com.")) {
                SecureField("sk-...", text: $apiKey)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                Button("Save Key") {
                    KeychainStore.saveAPIKey(apiKey.trimmingCharacters(in: .whitespacesAndNewlines))
                    savedConfirmation = true
                }
                .disabled(apiKey.isEmpty)

                if KeychainStore.loadAPIKey() != nil {
                    Button("Remove Key", role: .destructive) {
                        KeychainStore.deleteAPIKey()
                        apiKey = ""
                    }
                }
            }
        }
        .navigationTitle("AI Settings")
        .alert("Saved", isPresented: $savedConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your API key has been saved.")
        }
    }
}
