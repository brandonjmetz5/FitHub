//
//  MultiExerciseBuilderView.swift
//  FitHub
//
//  Created by brandon metz on 6/23/25.
//

import SwiftUI

struct MultiExerciseBuilderView: View {
    @EnvironmentObject private var templatesVM: WorkoutTemplatesViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - State
    @State private var workoutName: String = ""
    @State private var entries: [ExerciseEntry] = []
    @State private var saveAsTemplate: Bool = false

    /// Called when user finishes building: (newTemplate?, entries)
    let onComplete: (WorkoutTemplate?, [ExerciseEntry]) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Workout Name")) {
                    TextField("Enter workout name", text: $workoutName)
                }

                Section {
                    NavigationLink("➕ Add Exercise") {
                        ExerciseSelectionView { exercise in
                            addExercise(exercise)
                        }
                        .environmentObject(templatesVM)
                    }
                }

                // Exercises List
                if !entries.isEmpty {
                    Section(header: Text("Exercises")) {
                        ForEach(entries) { entry in
                            ZStack(alignment: .leading) {
                                Image(ExerciseImageMapper.imageMap[entry.exercise.name] ?? "defaultgymCard")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 100)
                                    .clipped()
                                    .cornerRadius(8)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(entry.exercise.name)
                                        .font(.headline)
                                        .foregroundColor(.white)

                                    HStack {
                                        if entry.exercise.inputType == .strength {
                                            Stepper("Sets: \(entry.sets)", value: binding(for: entry).sets, in: 1...10)
                                            Spacer()
                                            Stepper("Reps: \(entry.reps)", value: binding(for: entry).reps, in: 1...50)
                                        } else {
                                            Stepper("Duration: \(Int(entry.duration ?? 0))s", value: binding(for: entry).duration.unwrap(or: 30), in: 10...3600)
                                        }
                                    }
                                    .foregroundColor(.white)

                                    if entry.exercise.inputType == .strength {
                                        HStack {
                                            Text("Weight")
                                                .foregroundColor(.white)
                                            TextField("kg", value: binding(for: entry).weight.unwrap(or: 0), formatter: NumberFormatter())
                                                .keyboardType(.decimalPad)
                                                .frame(width: 60)
                                        }
                                        .foregroundColor(.white)
                                    }
                                }
                                .padding()
                                .background(Color.black.opacity(0.4))
                                .cornerRadius(8)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { indexSet in
                            entries.remove(atOffsets: indexSet)
                        }
                    }
                }

                Section {
                    Toggle("Save as Template", isOn: $saveAsTemplate)
                }

                Section {
                    Button(saveAsTemplate ? "Save & Log Workout" : "Log Workout") {
                        completeBuild()
                    }
                    .disabled(workoutName.isEmpty || entries.isEmpty)
                }
            }
            .navigationTitle("Build Workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Helpers
    private func addExercise(_ exercise: Exercise) {
        // Prevent duplicates
        if !entries.contains(where: { $0.exercise.name == exercise.name }) {
            entries.append(
                ExerciseEntry(
                    exercise: exercise,
                    sets: 3,
                    reps: 10,
                    weight: exercise.inputType == .strength ? 0 : nil,
                    duration: exercise.inputType == .cardio ? 60 : nil
                )
            )
        }
    }

    private func binding(for entry: ExerciseEntry) -> Binding<ExerciseEntry> {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else {
            fatalError("Entry not found")
        }
        return $entries[index]
    }

    private func completeBuild() {
        var newTemplate: WorkoutTemplate? = nil
        if saveAsTemplate {
            var template = WorkoutTemplate(
                id: nil,
                name: workoutName,
                isPreset: false,
                userId: nil,
                exercises: entries.map { $0.exercise }
            )
            templatesVM.createCustomTemplate(template)
            newTemplate = template
        }
        onComplete(newTemplate, entries)
        dismiss()
    }
}

// Helpers for optional bindings
extension Binding where Value == Double? {
    func unwrap(or defaultValue: Double) -> Binding<Double> {
        Binding<Double>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
}
