//
//  ProfileView.swift
//  FitHub
//
//  Created by brandon metz on 6/22/25.
//

import SwiftUI

struct ProfileView: View {
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

    // UI state
    @State private var showSuccessAlert = false
    @FocusState private var isInputActive: Bool

    // Keep the last saved profile around to compare for "dirty" state
    @State private var originalProfile: UserProfile?

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal") {
                    HStack {
                        TextField("Age", text: $age)
                            .keyboardType(.numberPad)
                            .focused($isInputActive)
                        Text("yrs").foregroundColor(.secondary)
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
                                .focused($isInputActive)
                            Text("ft").foregroundColor(.secondary)
                        }
                        HStack {
                            TextField("in", text: $heightIn)
                                .keyboardType(.numberPad)
                                .focused($isInputActive)
                            Text("in").foregroundColor(.secondary)
                        }
                    }
                    HStack {
                        TextField("Weight", text: $weightLb)
                            .keyboardType(.decimalPad)
                            .focused($isInputActive)
                        Text("lbs").foregroundColor(.secondary)
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
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        updateProfile()
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Update")
                        }
                    }
                    // Only enabled if valid AND dirty AND not already loading
                    .disabled(!canSave || !isDirty || viewModel.isLoading)
                }
            }
            .alert("Profile Updated", isPresented: $showSuccessAlert) {
                Button("OK") { }
            } message: {
                Text("Your profile has been successfully updated.")
            }
            .onAppear {
                populateFields()
            }
        }
    }

    // MARK: - Validation

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

    // MARK: - Dirty check

    private var isDirty: Bool {
        guard let original = originalProfile else { return false }
        // Compare each field by converting back to model values
        let ageInt = Int(age) ?? original.age
        let totalIn = (Double(heightFt) ?? 0) * 12 + (Double(heightIn) ?? 0)
        let heightCmNew = totalIn * 2.54
        let weightKgNew = (Double(weightLb) ?? 0) * 0.453592
        let splitNew = selectedPreset.split
        let rateNew = goal == .maintainWeight ? 0 : weeklyRate

        return ageInt           != original.age
            || sex              != original.sex
            || abs(heightCmNew - original.heightCm) > 0.1
            || abs(weightKgNew - original.weightKg) > 0.1
            || activityLevel    != original.activityLevel
            || goal             != original.goal
            || rateNew           != original.weeklyRateLbs
            || splitNew          != original.macroSplit
    }

    // MARK: - Populate

    private func populateFields() {
        guard let profile = viewModel.profile else { return }
        originalProfile = profile  // stash it

        age = String(profile.age)
        sex = profile.sex

        let totalInches = profile.heightCm / 2.54
        let ft = Int(totalInches / 12)
        let inches = Int(totalInches) % 12
        heightFt = String(ft)
        heightIn = String(inches)

        weightLb = String(format: "%.0f", profile.weightKg * 2.20462)

        activityLevel = profile.activityLevel
        goal = profile.goal
        weeklyRate = profile.weeklyRateLbs > 0 ? profile.weeklyRateLbs : 0.5

        if let match = MacroPreset.allCases.first(where: {
            $0.split == profile.macroSplit
        }) {
            selectedPreset = match
        } else {
            selectedPreset = .balanced
        }
    }

    // MARK: - Save

    private func updateProfile() {
        guard
            let ageInt = Int(age),
            let ft = Double(heightFt),
            let inch = Double(heightIn),
            let wlb = Double(weightLb)
        else { return }

        // Dismiss keyboard
        isInputActive = false

        let totalInches = ft * 12 + inch
        let heightCm = totalInches * 2.54
        let weightKg = wlb * 0.453592

        let profile = UserProfile(
            id: viewModel.profile?.id,
            age: ageInt,
            sex: sex,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: activityLevel,
            goal: goal,
            weeklyRateLbs: goal == .maintainWeight ? 0 : weeklyRate,
            macroSplit: selectedPreset.split
        )

        viewModel.saveProfile(profile) { success in
            if success {
                showSuccessAlert = true
                // update our “original” snapshot
                originalProfile = profile
            }
        }
    }
}
