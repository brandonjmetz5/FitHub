//
//  ProfileView.swift
//  FitHub
//
//  Created by brandon metz on 6/22/25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel

    // MARK: - Personal
    @State private var age = ""
    @State private var sex: String = "Male"
    private let sexes = ["Male", "Female"]

    // MARK: - Body (US units)
    @State private var heightFt = ""
    @State private var heightIn = ""
    @State private var startWeightLb = ""  // starting weight
    @State private var goalWeightLb = ""   // target weight

    // MARK: - Activity
    @State private var activityLevel: ActivityLevel = .moderatelyActive

    // MARK: - Goal & Rate
    @State private var goal: GoalType = .maintainWeight
    @State private var weeklyRate: Double = 0.5
    private let rates: [Double] = [0.5, 1.0, 1.5, 2.0]
    private let rateLabels: [Double:String] = [
        0.5: "0.5 lb/week (Slow)",
        1.0: "1.0 lb/week (Moderate)",
        1.5: "1.5 lb/week (Aggressive)",
        2.0: "2.0 lb/week (Very Aggressive)"
    ]

    // MARK: - Macro split
    @State private var selectedPreset: MacroPreset = .balanced

    // MARK: - UI state
    @State private var showSuccessAlert = false
    @FocusState private var isInputActive: Bool

    // Keep the last saved profile around to compare for dirty check
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
                        TextField("Starting Weight", text: $startWeightLb)
                            .keyboardType(.decimalPad)
                            .focused($isInputActive)
                        Text("lbs").foregroundColor(.secondary)
                    }
                    HStack {
                        TextField("Goal Weight", text: $goalWeightLb)
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
                                Text(rateLabels[rate]!).tag(rate)
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
            Double(startWeightLb) != nil,
            Double(goalWeightLb) != nil,
            goal == .maintainWeight || rates.contains(weeklyRate)
        else { return false }
        return true
    }

    // MARK: - Dirty check
    private var isDirty: Bool {
        guard let original = originalProfile else { return false }
        let ageInt      = Int(age) ?? original.age
        let ft          = Double(heightFt) ?? original.heightFeet
        let inch        = Double(heightIn) ?? original.heightInches
        let startLb     = Double(startWeightLb) ?? original.startWeightLb
        let goalLb      = Double(goalWeightLb)  ?? original.goalWeightLb
        let rateNew     = goal == .maintainWeight ? 0 : weeklyRate
        let splitNew    = selectedPreset.split

        return ageInt               != original.age
            || sex                  != original.sex
            || ft                   != original.heightFeet
            || inch                 != original.heightInches
            || startLb              != original.startWeightLb
            || goalLb               != original.goalWeightLb
            || activityLevel        != original.activityLevel
            || goal                 != original.goal
            || rateNew              != original.weeklyRateLbs
            || splitNew             != original.macroSplit
    }

    // MARK: - Populate
    private func populateFields() {
        guard let profile = viewModel.profile else { return }
        originalProfile = profile

        age              = String(profile.age)
        sex              = profile.sex
        heightFt         = String(format: "%.0f", profile.heightFeet)
        heightIn         = String(format: "%.0f", profile.heightInches)
        startWeightLb    = String(format: "%.0f", profile.startWeightLb)
        goalWeightLb     = String(format: "%.0f", profile.goalWeightLb)
        activityLevel    = profile.activityLevel
        goal             = profile.goal
        weeklyRate       = profile.weeklyRateLbs > 0 ? profile.weeklyRateLbs : 0.5
        selectedPreset   = MacroPreset.allCases.first(where: { $0.split == profile.macroSplit })
                            ?? .balanced
    }

    // MARK: - Save
    private func updateProfile() {
        guard
            let ageInt    = Int(age),
            let ft        = Double(heightFt),
            let inch      = Double(heightIn),
            let startLb   = Double(startWeightLb),
            let goalLb    = Double(goalWeightLb)
        else { return }

        let profile = UserProfile(
            id: viewModel.profile?.id,
            age: ageInt,
            sex: sex,
            heightFeet: ft,
            heightInches: inch,
            startWeightLb: startLb,
            goalWeightLb: goalLb,
            activityLevel: activityLevel,
            goal: goal,
            weeklyRateLbs: goal == .maintainWeight ? 0 : weeklyRate,
            macroSplit: selectedPreset.split
        )

        viewModel.saveProfile(profile) { success in
            if success {
                showSuccessAlert = true
                originalProfile = profile
            }
        }
    }
}
