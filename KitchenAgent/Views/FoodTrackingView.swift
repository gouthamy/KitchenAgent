//
//  FoodTrackingView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct FoodTrackingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var mealPlans: [MealPlan]
    @Query private var foodLogs: [FoodLog]

    @State private var selectedDate = Date()
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var selectedImage: UIImage?
    @State private var isAnalyzing = false

    private var activeMealPlan: MealPlan? {
        mealPlans.first(where: { $0.isActive })
    }

    private var todayLogs: [FoodLog] {
        foodLogs.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: selectedDate) }
    }

    private var todayTotals: (calories: Int, protein: Double, carbs: Double, fat: Double) {
        let calories = todayLogs.reduce(0) { $0 + $1.calories }
        let protein = todayLogs.reduce(0.0) { $0 + $1.protein }
        let carbs = todayLogs.reduce(0.0) { $0 + $1.carbs }
        let fat = todayLogs.reduce(0.0) { $0 + $1.fat }
        return (calories, protein, carbs, fat)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Date Selector
                    dateSelector

                    // Progress Rings
                    if let plan = activeMealPlan {
                        progressSection(plan: plan)
                    }

                    // Quick Add Buttons
                    quickAddButtons

                    // Today's Food Log
                    foodLogSection
                }
                .padding()
            }
            .background(Theme.Colors.background)
            .navigationTitle("Food Tracking")
            .sheet(isPresented: $showingPhotoPicker) {
                PhotoPickerView(selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showingCamera) {
                CameraView(selectedImage: $selectedImage)
            }
            .onChange(of: selectedImage) { _, newImage in
                if let image = newImage {
                    analyzeFoodImage(image)
                }
            }
        }
    }

    // MARK: - Date Selector
    private var dateSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.md) {
                ForEach(-3..<4, id: \.self) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
                    DateButton(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    ) {
                        selectedDate = date
                    }
                }
            }
        }
    }

    // MARK: - Progress Section
    private func progressSection(plan: MealPlan) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Today's Progress")
                .font(.headline)

            VStack(spacing: Theme.Spacing.md) {
                // Calories Ring
                ProgressRingView(
                    progress: Double(todayTotals.calories) / Double(plan.dailyCalorieTarget),
                    value: "\(todayTotals.calories)",
                    goal: "\(plan.dailyCalorieTarget)",
                    label: "Calories",
                    color: .orange
                )

                HStack(spacing: Theme.Spacing.lg) {
                    // Protein
                    MiniProgressRing(
                        progress: todayTotals.protein / plan.dailyProteinTarget,
                        value: "\(Int(todayTotals.protein))g",
                        goal: "\(Int(plan.dailyProteinTarget))g",
                        label: "Protein",
                        color: .red
                    )

                    // Carbs
                    MiniProgressRing(
                        progress: todayTotals.carbs / plan.dailyCarbsTarget,
                        value: "\(Int(todayTotals.carbs))g",
                        goal: "\(Int(plan.dailyCarbsTarget))g",
                        label: "Carbs",
                        color: .blue
                    )

                    // Fat
                    MiniProgressRing(
                        progress: todayTotals.fat / plan.dailyFatTarget,
                        value: "\(Int(todayTotals.fat))g",
                        goal: "\(Int(plan.dailyFatTarget))g",
                        label: "Fat",
                        color: .purple
                    )
                }
            }
            .padding()
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.lg)
        }
    }

    // MARK: - Quick Add Buttons
    private var quickAddButtons: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Log Food")
                .font(.headline)

            HStack(spacing: Theme.Spacing.md) {
                Button {
                    showingCamera = true
                } label: {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Take Photo")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(Theme.CornerRadius.md)
                }

                Button {
                    showingPhotoPicker = true
                } label: {
                    HStack {
                        Image(systemName: "photo.fill")
                        Text("From Gallery")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.Colors.primary.opacity(0.2))
                    .foregroundColor(Theme.Colors.primary)
                    .cornerRadius(Theme.CornerRadius.md)
                }
            }
        }
    }

    // MARK: - Food Log Section
    private var foodLogSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Food Log")
                .font(.headline)

            if todayLogs.isEmpty {
                emptyStateView
            } else {
                ForEach(todayLogs) { log in
                    FoodLogCard(log: log)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "fork.knife")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No food logged today")
                .font(.headline)
            Text("Take a photo of your meal to track nutrition")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xxl)
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
    }

    // MARK: - Analyze Food Image
    private func analyzeFoodImage(_ image: UIImage) {
        isAnalyzing = true

        Task {
            do {
                let nutrition = try await FoodRecognitionService.shared.analyzeFoodImage(image)

                await MainActor.run {
                    let foodLog = FoodLog(
                        foodName: nutrition.foodName,
                        mealType: determineMealType(),
                        calories: nutrition.calories,
                        protein: nutrition.protein,
                        carbs: nutrition.carbs,
                        fat: nutrition.fat,
                        servingSize: nutrition.servingSize,
                        imageData: image.jpegData(compressionQuality: 0.7),
                        timestamp: selectedDate
                    )

                    modelContext.insert(foodLog)
                    try? modelContext.save()

                    isAnalyzing = false
                    selectedImage = nil
                }
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                    selectedImage = nil
                    print("Failed to analyze food: \(error)")
                }
            }
        }
    }

    private func determineMealType() -> MealType {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<10: return .breakfast
        case 10..<12: return .morningSnack
        case 12..<16: return .lunch
        case 16..<19: return .eveningSnack
        default: return .dinner
        }
    }
}

// MARK: - Supporting Views

struct ProgressRingView: View {
    let progress: Double
    let value: String
    let goal: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6), value: progress)

                VStack(spacing: 4) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("/ \(goal)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

struct MiniProgressRing: View {
    let progress: Double
    let value: String
    let goal: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 6)
                    .frame(width: 60, height: 60)

                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6), value: progress)

                Text(value)
                    .font(.caption2)
                    .fontWeight(.bold)
            }

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct FoodLogCard: View {
    let log: FoodLog

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Food Image
            if let imageData = log.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.sm))
            } else {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                    .fill(Theme.Colors.primary.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "fork.knife")
                            .foregroundColor(Theme.Colors.primary)
                    )
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(log.foodName)
                    .font(.headline)
                Text(log.mealType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: Theme.Spacing.sm) {
                    Text("\(log.calories) cal")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("•")
                        .foregroundColor(.secondary)
                    Text("P: \(Int(log.protein))g")
                        .font(.caption)
                        .foregroundColor(.red)
                    Text("C: \(Int(log.carbs))g")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("F: \(Int(log.fat))g")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }

            Spacer()

            Text(log.timestamp.formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
    }
}

struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView

        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }

            provider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    self.parent.selectedImage = image as? UIImage
                }
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    FoodTrackingView()
        .modelContainer(for: [MealPlan.self, FoodLog.self], inMemory: true)
}
