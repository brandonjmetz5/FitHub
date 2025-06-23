//
//  WorkoutLogView.swift
//  FitHub
//
//  Created by brandon metz on 6/23/25.
//

import SwiftUI

struct WorkoutLogView: View {
    @EnvironmentObject var templatesVM: WorkoutTemplatesViewModel
    @StateObject private var logVM = WorkoutLogViewModel()

    /// All logs from today
    private var todayLogs: [WorkoutLog] {
        let todayStart = Calendar.current.startOfDay(for: Date())
        return logVM.logs.filter {
            Calendar.current.isDate($0.date, inSameDayAs: todayStart)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(todayLogs, id: \.id) { log in
                        NavigationLink(destination: CardDetailView(log: log)) {
                            ZStack {
                                // Background image (first exercise)
                                if let first = log.performedExercises.first {
                                    Image(ExerciseImageMapper.imageMap[first.exercise.name] ?? "defaultgymCard")
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

                                // Top-left: delete button only
                                Button {
                                    logVM.deleteWorkoutLog(log)
                                } label: {
                                    Image(systemName: "trash.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                                // Details overlay on right edge
                                VStack(alignment: .trailing, spacing: 6) {
                                    Text(workoutName(for: log))
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(log.date, style: .time)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    Text("\(log.performedExercises.count) exercises")
                                        .font(.subheadline)
                                        .foregroundColor(.white)

                                    let totalSets = log.performedExercises.reduce(0) { $0 + $1.sets }
                                    let totalSeconds = log.performedExercises.reduce(0) { $0 + Int($1.duration ?? 0) }
                                    let totalMinutes = totalSeconds / 60
                                    Text("\(totalSets) sets • \(totalMinutes)m")
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
                }
                .padding()
            }
            .navigationTitle("Today's Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        WorkoutPickerView(onSelect: { template in
                            handleNewLog(template: template)
                        })
                        .environmentObject(templatesVM)
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Log Workout")
                        }
                    }
                }
            }
            .onAppear {
                logVM.fetchAllLogs()
            }
        }
    }

    // MARK: - Helpers

    private func workoutName(for log: WorkoutLog) -> String {
        if let id = log.templateID {
            if let custom = templatesVM.customTemplates.first(where: { $0.id == id }) {
                return custom.name
            }
            if let preset = templatesVM.presets.first(where: { $0.id == id }) {
                return preset.name
            }
        }
        return "Workout"
    }

    private func handleNewLog(template: WorkoutTemplate) {
        let entries = template.exercises.map { exercise in
            ExerciseEntry(
                exercise: exercise,
                sets: 3,
                reps: 10,
                weight: exercise.inputType == .strength ? 0 : nil,
                duration: exercise.inputType == .cardio ? 60 : nil
            )
        }
        logVM.logWorkout(using: template, with: entries)
    }
}

// MARK: - Detail View
struct CardDetailView: View {
    let log: WorkoutLog

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(log.date, style: .date)
                    .font(.largeTitle)
                    .padding(.top)

                ForEach(log.performedExercises) { entry in
                    ZStack(alignment: .bottomLeading) {
                        Image(ExerciseImageMapper.imageMap[entry.exercise.name] ?? "defaultgymCard")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                            .cornerRadius(10)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.exercise.name)
                                .font(.headline)
                                .foregroundColor(.white)
                            if entry.exercise.inputType == .strength {
                                Text("Sets: \(entry.sets), Reps: \(entry.reps)")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            } else {
                                Text("Duration: \(Int(entry.duration ?? 0))s")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .padding(8)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Workout Details")
    }
}

struct WorkoutLogView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutLogView()
            .environmentObject(WorkoutTemplatesViewModel())
    }
}
