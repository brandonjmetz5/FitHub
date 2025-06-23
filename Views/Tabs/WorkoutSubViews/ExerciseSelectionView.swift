//
//  ExerciseSelectionView.swift
//  FitHub
//
//  Created by brandon metz on 6/23/25.

import SwiftUI

/// View for searching and selecting an exercise from the master list.
struct ExerciseSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    /// Called when an exercise is selected
    let onSelect: (Exercise) -> Void

    // Filtered and sorted exercises based on search text
    private var exercises: [Exercise] {
        let list = searchText.isEmpty
            ? ExerciseLibrary.all
            : ExerciseLibrary.all.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        return list.sorted { $0.name < $1.name }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(exercises) { exercise in
                    ExerciseCard(exercise: exercise) {
                        onSelect(exercise)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search exercises")
        .navigationTitle("Add Exercise")
    }
}

/// A card view showing an exercise image and name.
struct ExerciseCard: View {
    let exercise: Exercise
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                Image(ExerciseImageMapper.imageMap[exercise.name] ?? "defaultgymCard")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(12)
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .padding(6)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Maps exercise names to asset image names
struct ExerciseImageMapper {
    static let imageMap: [String: String] = [
        "Running": "runningCard",
        "Cycling": "cyclingCard",
        "Jump Rope": "jumpropeCard",
        "Burpees": "cardiogymCard",
        "Mountain Climbers": "gymdefaultCard",
        "Box Jumps": "boxjumpCard",
        "Rowing Machine": "rowmachineCard",
        "Stair Climber": "stairclimberCard",
        "Walking": "cardiogymCard",
        "Treadmill": "treadmillCard",
        "Elliptical": "cardiogymCard",
        "High Knees": "cardiogymCard",
        "Jumping Jacks": "cardiogymCard",
        "Battle Ropes": "battleropesCard",
        "Shadow Boxing": "shadowboxingCard",
        "Swimming": "swimmingCard",
        "Hiking": "hikingCard",
        "Dance Cardio": "cardiogymCard",
        "Sled Push": "sledpushCard",
        
        "Bench Press": "benchpressCard",
        "Incline Bench Press": "benchpressCard",
        "Dumbbell Press": "dumbellpressCard",
        "Push-ups": "pushupCard",
        "Weighted Push-ups": "pushupCard",
        "Pull-ups": "pullupCard",
        "Weighted Pull-ups": "pullupCard",
        "Chest Fly": "chestflyCard",
        "Cable Crossover": "cablecrossCard",
        "Squat": "squatCard",
        "Front Squat": "squatCard",
        "Goblet Squat": "squatCard",
        "Leg Extension": "legextCard",
        "Leg Curl": "legcurlCard",
        "Leg Press": "legpressCard",
        "Deadlift": "deadliftCard",
        "Romanian Deadlift": "deadliftCard",
        "Sumo Deadlift": "deadliftCard",
        "Shoulder Press": "shoulderpressCard",
        "Lateral Raises": "latraiseCard",
        "Barbell Row": "barbellrowCard",
        "Dumbbell Row": "dumbellrowCard",
        "Lat Pulldown": "latpulldownCard",
        "Face Pull": "facepullCard",
        "Tricep Pushdown": "triceppushownCard",
        "Skull Crushers": "defaultgymCard",
        "Overhead Extension": "defaultgymCard",
        "Barbell Curl": "barbellcurlCard",
        "Hammer Curl": "hammercurlCard",
        "Cable Curl": "cablecurlCard",
        "Preacher Curl": "preachercurlCard",
        "Hip Thrust": "hipthrustCard",
        "Calf Raises": "calfraiseCard",
        "Seated Calf Raise": "calfraiseCard",
        
        "Plank": "defaultgymCard",
        "Side Plank": "defaultgymCard",
        "Wall Sit": "defaultgymCard",
        "Hollow Body Hold": "defaultgymCard",
        "Leg Lifts": "defaultgymCard",
        "Bicycle Crunches": "bicyclecrunchCard",
        "Superman Hold": "supermanCard",
        "V-Ups": "vupCard",
        "Flutter Kicks": "flutterCard",
        "Toe Touches": "totouchCard",
        "Russian Twists": "kttlebelltwistCard",
        "Seated Knee Tucks": "kneetuckCard",
        "Cable Crunches": "cablecrunchCard",
        "Hanging Leg Raises": "hanglegraiseCard"
    ]
}
