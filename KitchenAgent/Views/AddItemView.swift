//
//  AddItemView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedImage: PhotosPickerItem?
    @State private var capturedImage: UIImage?
    @State private var showCamera = false
    @State private var isProcessing = false

    @State private var itemName = ""
    @State private var quantity = ""
    @State private var selectedLocation: StorageLocation = .fridge
    @State private var purchaseDate = Date()
    @State private var expiryDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var notes = ""
    @State private var selectedCategory: ItemCategory = .vegetable

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 16) {
                        if let image = capturedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green, lineWidth: 2)
                                )
                        } else {
                            Circle()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.green)
                                )
                        }

                        HStack(spacing: 12) {
                            PhotosPicker(selection: $selectedImage, matching: .images) {
                                Label("Gallery", systemImage: "photo.on.rectangle")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .foregroundColor(.green)
                                    .cornerRadius(10)
                            }

                            Button {
                                showCamera = true
                            } label: {
                                Label("Camera", systemImage: "camera")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .foregroundColor(.green)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section("Item Details") {
                    TextField("Item Name", text: $itemName)
                        .foregroundColor(.primary)

                    HStack {
                        TextField("Quantity", text: $quantity)
                            .keyboardType(.decimalPad)
                            .foregroundColor(.primary)
                        Text("g")
                            .foregroundColor(.secondary)
                    }

                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ItemCategory.allCases, id: \.self) { category in
                            Text("\(category.icon) \(category.rawValue)")
                                .tag(category)
                        }
                    }
                }

                Section("Dates") {
                    DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)
                    DatePicker("Expiry Date (Optional)", selection: $expiryDate, displayedComponents: .date)
                }

                Section("Storage") {
                    Picker("Location", selection: $selectedLocation) {
                        ForEach(StorageLocation.allCases, id: \.self) { location in
                            Label(location.rawValue, systemImage: location.icon)
                                .tag(location)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Notes (Optional)") {
                    TextField("e.g., Fresh tomatoes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundColor(.primary)
                }

                if isProcessing {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Text("Analyzing image...")
                                .padding(.leading)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save Item") {
                        saveItem()
                    }
                    .fontWeight(.semibold)
                    .disabled(itemName.isEmpty || quantity.isEmpty)
                }
            }
            .onChange(of: selectedImage) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        capturedImage = image
                        await processImage(image)
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView(capturedImage: $capturedImage, onCapture: { image in
                    Task {
                        await processImage(image)
                    }
                })
            }
        }
    }

    private func processImage(_ image: UIImage) async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            let recognizedItems = try await ImageRecognitionService.shared.recognizeFood(from: image)

            if let firstItem = recognizedItems.first {
                await MainActor.run {
                    itemName = firstItem.name
                    quantity = String(format: "%.0f", firstItem.estimatedQuantity)
                    selectedCategory = firstItem.category

                    let estimatedExpiry = ImageRecognitionService.shared.estimateExpiryDate(
                        for: firstItem.name,
                        from: purchaseDate
                    )
                    expiryDate = estimatedExpiry
                }
            }
        } catch {
            print("Error processing image: \(error)")
        }
    }

    private func saveItem() {
        let imageData = capturedImage?.jpegData(compressionQuality: 0.7)
        let quantityValue = Double(quantity) ?? 0

        let newItem = FridgeItem(
            name: itemName,
            quantity: quantityValue,
            unit: "g",
            purchaseDate: purchaseDate,
            expiryDate: expiryDate,
            location: selectedLocation,
            notes: notes.isEmpty ? nil : notes,
            imageData: imageData,
            category: selectedCategory
        )

        modelContext.insert(newItem)

        // Schedule notification
        NotificationService.shared.scheduleExpiryReminder(for: newItem)

        dismiss()
    }
}

#Preview {
    AddItemView()
        .modelContainer(for: FridgeItem.self, inMemory: true)
}
