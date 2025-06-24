//
//  HomeView.swift
//  FitHub
//
//  Created by brandon metz on 6/24/25.
//

import SwiftUI
import Charts

struct HomeView: View {
    @Binding var selectedTab: Tab

    @StateObject private var weightVM = WeightLogViewModel()
    @StateObject private var foodVM = FoodLogViewModel()
    @StateObject private var workoutVM = WorkoutLogViewModel()
    @EnvironmentObject var profileViewModel: ProfileViewModel

    @State private var showingLogWeight = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Today's Snapshot
                VStack(alignment: .leading, spacing: 16) {
                    Text("Today's Snapshot")
                        .font(.title2).bold()

                    // Weight Card
                    if let latest = weightVM.latestLog,
                       Calendar.current.isDateInToday(latest.date) {
                        HStack {
                            Image(systemName: "scalemass")
                            Text("Weight: \(String(format: "%.1f", latest.weight)) lbs")
                        }
                    } else {
                        Button(action: { showingLogWeight = true }) {
                            HStack {
                                Image(systemName: "scalemass")
                                Text("Log Today's Weight").bold()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }

                    // Calorie & Macro Progress
                    if let profile = profileViewModel.profile {
                        VStack(spacing: 8) {
                            ProgressView(
                                "Calories",
                                value: foodVM.totalCalories,
                                total: profile.calorieTarget
                            )
                            ProgressView(
                                "Protein",
                                value: foodVM.totalProtein,
                                total: profile.proteinTarget
                            )
                            ProgressView(
                                "Carbs",
                                value: foodVM.totalCarbs,
                                total: profile.carbsTarget
                            )
                            ProgressView(
                                "Fat",
                                value: foodVM.totalFat,
                                total: profile.fatTarget
                            )
                        }
                        .progressViewStyle(.linear)
                    }

                    // Workout Status
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Workout Status").font(.headline)
                        if let todayWorkout = workoutVM.todayWorkout {
                            let count = todayWorkout.performedExercises.count
                            Text("Logged: \(count) exercise\(count == 1 ? "" : "s")")
                        } else {
                            Button("Log Workout") {
                                selectedTab = .workouts
                            }
                        }
                    }

                    // Food Status
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Food Status").font(.headline)
                        if foodVM.todaysEntries.isEmpty {
                            Button("Log Food") {
                                selectedTab = .log
                            }
                        }
                    }
                }
                .padding()

                // Progress Trends
                VStack(alignment: .leading, spacing: 16) {
                    Text("Progress Trends").font(.title2).bold()

                    Chart {
                        ForEach(weightVM.logs) { log in
                            LineMark(
                                x: .value("Date", log.date),
                                y: .value("Weight", log.weight)
                            )
                        }
                    }
                    .frame(height: 150)

                    Chart {
                        ForEach(foodVM.weeklyCalories) { entry in
                            BarMark(
                                x: .value("Date", entry.date),
                                y: .value("Calories", entry.calories)
                            )
                        }
                    }
                    .frame(height: 150)
                }
                .padding()

                // Upcoming & Streaks
                VStack(alignment: .leading, spacing: 8) {
                    Text("Upcoming & Streaks").font(.title2).bold()

                    DatePicker(
                        "",
                        selection: .constant(Date()),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .frame(height: 200)

                    Text("Food Log Streak: \(foodVM.streak) days")
                    if let next = workoutVM.nextPlannedWorkout {
                        Text("Next Workout: \(next.name)")
                    } else {
                        Text("Next Workout: None")
                    }
                }
                .padding()
            }
            .onAppear {
                weightVM.fetchLogs()
                foodVM.fetchTodaysEntries()
                workoutVM.fetchAllLogs()
                foodVM.fetchWeeklyCalories()
                workoutVM.fetchNextWorkout()
            }
        }
        .sheet(isPresented: $showingLogWeight) {
            LogWeightView()
                .environmentObject(weightVM)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectedTab: .constant(.home))
            .environmentObject(ProfileViewModel())
            .environmentObject(WeightLogViewModel())
            .environmentObject(FoodLogViewModel())
            .environmentObject(WorkoutLogViewModel())
    }
}
