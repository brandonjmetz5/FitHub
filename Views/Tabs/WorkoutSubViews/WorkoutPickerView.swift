//  WorkoutPickerView.swift
//  FitHub
//
//  Created by Brandon Metz on 6/23/25.
//  Updated 6/29/25 to display saved workouts in card style matching WorkoutLogView

import SwiftUI

struct WorkoutPickerView: View {
    @EnvironmentObject var templatesVM: WorkoutTemplatesViewModel
    @Environment(\.dismiss) private var dismiss

    /// Called when a template is selected (existing or newly created)
    let onSelect: (WorkoutTemplate) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    // My Workouts cards
                    ForEach(templatesVM.customTemplates, id: \.id) { template in
                        Button {
                            onSelect(template)
                            dismiss()
                        } label: {
                            ZStack {
                                // Background image from first exercise
                                if let first = template.exercises.first {
                                    Image(ExerciseImageMapper.imageMap[first.name] ?? "defaultgymCard")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 138)
                                        .clipped()
                                        .cornerRadius(12)
                                } else {
                                    Color.gray
                                        .frame(height: 138)
                                        .cornerRadius(12)
                                }

                                // Top-left delete button
                                Button {
                                    templatesVM.deleteCustomTemplate(template)
                                } label: {
                                    Image(systemName: "trash.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                                // Details overlay on right edge
                                VStack(alignment: .trailing, spacing: 6) {
                                    Text(template.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("\(template.exercises.count) exercises")
                                        .font(.subheadline)
                                        .foregroundColor(.white)

                                    // Optionally show total sets preview
                                    let totalSets = template.exercises.reduce(0) { $0 + ($1.inputType == .strength ? 3 : 0) }
                                    Text("\(totalSets) sets")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.black.opacity(0.4))
                                .cornerRadius(8)
                                .padding(8)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            }
                        }
                    }

                    // Add New Workout card
                    NavigationLink {
                        MultiExerciseBuilderView { newTemplate, _ in
                            if let t = newTemplate {
                                onSelect(t)
                            }
                            dismiss()
                        }
                        .environmentObject(templatesVM)
                    } label: {
                        ZStack {
                            Color.blue
                                .frame(height: 138)
                                .cornerRadius(12)

                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.largeTitle)
                                Text("Add New Workout")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("My Workouts")
            .onAppear {
                templatesVM.fetchCustomTemplates()
            }
        }
    }
}

struct WorkoutPickerView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutPickerView { _ in }
            .environmentObject(WorkoutTemplatesViewModel())
    }
}
