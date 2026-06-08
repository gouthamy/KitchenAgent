//
//  SettingsView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [UserSettings]

    private var userSettings: UserSettings {
        if let existing = settings.first {
            return existing
        } else {
            let newSettings = UserSettings()
            modelContext.insert(newSettings)
            return newSettings
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                // Profile Section
                Section {
                    HStack(spacing: 16) {
                        if let imageData = userSettings.profileImageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text(String(userSettings.userName.prefix(1)))
                                        .font(.title)
                                        .foregroundColor(.green)
                                )
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(userSettings.userName)
                                .font(.headline)
                            Text(userSettings.userEmail)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        NavigationLink {
                            ProfileEditView(settings: userSettings)
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Notifications
                Section(header: Text("Notifications")) {
                    Toggle(isOn: Binding(
                        get: { userSettings.enableNotifications },
                        set: { newValue in
                            userSettings.enableNotifications = newValue
                            if !newValue {
                                NotificationService.shared.cancelAllNotifications()
                            }
                        }
                    )) {
                        Label("Enable Notifications", systemImage: "bell")
                    }

                    if userSettings.enableNotifications {
                        HStack {
                            Label("Reminder Time", systemImage: "clock")
                            Spacer()
                            DatePicker("", selection: Binding(
                                get: { userSettings.reminderTime },
                                set: { newValue in
                                    userSettings.reminderTime = newValue
                                    NotificationService.shared.scheduleDailyReminder(at: newValue)
                                }
                            ), displayedComponents: .hourAndMinute)
                            .labelsHidden()
                        }
                    }
                }

                // AI Features
                Section(header: Text("AI Features")) {
                    NavigationLink {
                        AISettingsView()
                    } label: {
                        HStack {
                            Label("ChatGPT API Key", systemImage: "brain.head.profile")
                            Spacer()
                            if let apiKey = UserDefaults.standard.string(forKey: "chatgpt_api_key"), !apiKey.isEmpty {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                            }
                        }
                    }
                    Text("Get AI-powered recipe suggestions based on your ingredients and preferences")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Preferences
                Section(header: Text("Preferences")) {
                    Picker(selection: Binding(
                        get: { userSettings.preferredUnit },
                        set: { userSettings.preferredUnit = $0 }
                    )) {
                        Text("Gram (g)").tag("Gram (g)")
                        Text("Kilogram (kg)").tag("Kilogram (kg)")
                        Text("Pound (lb)").tag("Pound (lb)")
                    } label: {
                        Label("Unit", systemImage: "scalemass")
                    }

                    NavigationLink {
                        RecipePreferencesView()
                    } label: {
                        Label("Recipe Preferences", systemImage: "fork.knife")
                    }
                }

                // Sharing
                Section(header: Text("Sharing")) {
                    Toggle(isOn: Binding(
                        get: { userSettings.enableFamilySharing },
                        set: { userSettings.enableFamilySharing = $0 }
                    )) {
                        Label("Family Sharing", systemImage: "person.2")
                    }

                    if userSettings.enableFamilySharing {
                        NavigationLink {
                            FamilySharingView()
                        } label: {
                            Label("Manage Family", systemImage: "person.2")
                        }
                    }
                }

                // About
                Section(header: Text("About")) {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About My Fridge", systemImage: "info.circle")
                    }

                    Button {
                        // Share feedback
                    } label: {
                        Label("Send Feedback", systemImage: "envelope")
                    }
                }

                // Logout
                Section {
                    Button(role: .destructive) {
                        // Logout action
                    } label: {
                        HStack {
                            Spacer()
                            Text("Log Out")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct ProfileEditView: View {
    @Bindable var settings: UserSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Profile") {
                TextField("Name", text: $settings.userName)
                    .foregroundColor(.primary)
                TextField("Email", text: $settings.userEmail)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .foregroundColor(.primary)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct FamilySharingView: View {
    var body: some View {
        List {
            Text("Family sharing coming soon!")
                .foregroundColor(.secondary)
        }
        .navigationTitle("Family Sharing")
    }
}

struct AboutView: View {
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Build")
                    Spacer()
                    Text("100")
                        .foregroundColor(.secondary)
                }
            }

            Section {
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
            }
        }
        .navigationTitle("About")
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: UserSettings.self, inMemory: true)
}
