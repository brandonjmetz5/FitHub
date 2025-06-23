//
//  ProfileSetupView.swift
//  FitHub
//
//  Created by brandon metz on 6/22/25.
//

import SwiftUI

// MARK: - Macro Split Presets
enum MacroPreset: String, CaseIterable, Identifiable {
    case balanced       = "Balanced (30P/40C/30F)"
    case highProtein    = "High Protein (40P/30C/30F)"
    case lowCarb        = "Low-Carb (30P/25C/45F)"
    case highCarb       = "High-Carb (20P/50C/30F)"

    var id: String { rawValue }
    var split: MacroSplit {
        switch self {
        case .balanced:    return MacroSplit(proteinRatio: 0.30, carbsRatio: 0.40, fatRatio: 0.30)
        case .highProtein: return MacroSplit(proteinRatio: 0.40, carbsRatio: 0.30, fatRatio: 0.30)
        case .lowCarb:     return MacroSplit(proteinRatio: 0.30, carbsRatio: 0.25, fatRatio: 0.45)
        case .highCarb:    return MacroSplit(proteinRatio: 0.20, carbsRatio: 0.50, fatRatio: 0.30)
        }
    }
    var description: String {
        switch self {
        case .balanced:    return "A well-rounded split for general health and energy."
        case .highProtein: return "Great for muscle retention and satiety when losing weight."
        case .lowCarb:     return "Keeps carbs lower; may help control blood sugar and weight."
        case .highCarb:    return "Good for endurance athletes and high-activity days."
        }
    }
}

struct ProfileSetupView: View {
    @ObservedObject var viewModel: ProfileViewModel

    // Personal
    @State private var age = ""
    @State private var sex: String = "Male"
    private let sexes = ["Male", "Female"]

    // Body (feet/inches + lbs)
    @State private var heightFt = ""
    @State private var heightIn = ""
    @State private var weightLb = ""

    // Activity
    @State private var activityLevel: ActivityLevel = .moderatelyActive

    // Goal & Rate
    @State private var goal: GoalType = .maintainWeight
    @State private var weeklyRate: Double = 0.5
    private let rates: [Double] = [0.5, 1.0, 1.5, 2.0]
    private let rateLabels: [Double:String] = [
        0.5: "0.5 lb/week (Slow)",
        1.0: "1.0 lb/week (Moderate)",
        1.5: "1.5 lb/week (Aggressive)",
        2.0: "2.0 lb/week (Very Aggressive)"
    ]

    // Macro split
    @State private var selectedPreset: MacroPreset = .balanced

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal") {
                    HStack {
                        TextField("Age", text: $age)
                            .keyboardType(.numberPad)
                        Text("yrs")
                            .foregroundColor(.secondary)
                    }
                    Picker("Sex", selection: $sex) {
                        ForEach(sexes, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Body") {
                    HStack {
                        HStack {
                            TextField("Height", text: $heightFt)
                                .keyboardType(.numberPad)
                            Text("ft")
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            TextField("in", text: $heightIn)
                                .keyboardType(.numberPad)
                            Text("in")
                                .foregroundColor(.secondary)
                        }
                    }
                    HStack {
                        TextField("Weight", text: $weightLb)
                            .keyboardType(.decimalPad)
                        Text("lbs")
                            .foregroundColor(.secondary)
                    }
                }

                Section("Activity Level") {
                    Picker("Activity", selection: $activityLevel) {
                        ForEach(ActivityLevel.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Goal") {
                    Picker("Goal", selection: $goal) {
                        ForEach(GoalType.allCases) { g in
                            Text(g.rawValue).tag(g)
                        }
                    }
                    .pickerStyle(.menu)

                    if goal != .maintainWeight {
                        Picker("Rate", selection: $weeklyRate) {
                            ForEach(rates, id: \.self) { rate in
                                Text(rateLabels[rate]!)
                                    .tag(rate)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                Section("Macro Split") {
                    Picker("Split", selection: $selectedPreset) {
                        ForEach(MacroPreset.allCases) { preset in
                            Text(preset.rawValue).tag(preset)
                        }
                    }
                    .pickerStyle(.menu)

                    Text(selectedPreset.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            .navigationTitle("Setup Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private var canSave: Bool {
        guard
            Int(age) != nil,
            !sex.isEmpty,
            Double(heightFt) != nil,
            Double(heightIn) != nil,
            Double(weightLb) != nil,
            goal == .maintainWeight || rates.contains(weeklyRate)
        else { return false }
        return true
    }

    private func saveProfile() {
        guard
            let ageInt = Int(age),
            let ft = Double(heightFt),
            let inch = Double(heightIn),
            let wlb = Double(weightLb)
        else { return }

        let totalInches = ft * 12 + inch
        let heightCm = totalInches * 2.54
        let weightKg = wlb * 0.453592

        let split = selectedPreset.split

        let profile = UserProfile(
            age: ageInt,
            sex: sex,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: activityLevel,
            goal: goal,
            weeklyRateLbs: goal == .maintainWeight ? 0 : weeklyRate,
            macroSplit: split
        )

        viewModel.saveProfile(profile) { _ in }
    }
}
