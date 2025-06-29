//
//  ExerciseSelectionView.swift
//  FitHub
//
//  Created by brandon metz on 6/23/25.

import SwiftUI
//
///// View for searching and selecting an exercise from the master list.
//struct ExerciseSelectionView: View {
//    @Environment(\.dismiss) private var dismiss
//    @State private var searchText: String = ""
//    /// Called when an exercise is selected
//    let onSelect: (Exercise) -> Void
//
//    // Filtered and sorted exercises based on search text
//    private var exercises: [Exercise] {
//        let list = searchText.isEmpty
//            ? ExerciseLibrary.all
//            : ExerciseLibrary.all.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
//        return list.sorted { $0.name < $1.name }
//    }
//
//    var body: some View {
//        ScrollView {
//            LazyVStack(spacing: 16) {
//                ForEach(exercises) { exercise in
//                    ExerciseCard(exercise: exercise) {
//                        onSelect(exercise)
//                        dismiss()
//                    }
//                    .frame(maxWidth: .infinity)
//                }
//            }
//            .padding()
//        }
//        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search exercises")
//        .navigationTitle("Add Exercise")
//    }
//}
//
///// A card view showing an exercise image and name.
//struct ExerciseCard: View {
//    let exercise: Exercise
//    let onTap: () -> Void
//
//    var body: some View {
//        Button(action: onTap) {
//            ZStack(alignment: .bottom) {
//                Image(ExerciseImageMapper.imageMap[exercise.name] ?? "defaultgymCard")
//                    .resizable()
//                    .scaledToFill()
//                    .frame(height: 120)
//                    .clipped()
//                    .cornerRadius(12)
//                Text(exercise.name)
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .padding(6)
//                    .background(Color.black.opacity(0.6))
//                    .cornerRadius(8)
//                    .padding(6)
//            }
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//}


import SwiftUI

//struct ExerciseSelectionView: View {
//    @Environment(\.dismiss) private var dismiss
//    @State private var searchText: String = ""
//    let onSelect: (Exercise) -> Void
//
//    private var exercises: [Exercise] {
//        let list = searchText.isEmpty
//            ? ExerciseLibrary.all
//            : ExerciseLibrary.all.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
//        return list.sorted { $0.name < $1.name }
//    }
//
//    private let gridColumns = [
//        GridItem(.flexible(), spacing: 16),
//        GridItem(.flexible(), spacing: 16)
//    ]
//
//    var body: some View {
//        ZStack {
//            Color.primaryBackground.ignoresSafeArea()
//
//            ScrollView {
//                LazyVGrid(columns: gridColumns, spacing: 16) {
//                    ForEach(exercises) { exercise in
//                        ExerciseCard(exercise: exercise) {
//                            onSelect(exercise)
//                            dismiss()
//                        }
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.top, 16)
//            }
//        }
//        .navigationTitle("Add Exercise")
//        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search exercises")
//    }
//}

import SwiftUI

struct ExerciseSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    let onSelect: (Exercise) -> Void

    // Group filtered exercises by muscle group
    private var filteredExercisesByMuscleGroup: [MuscleGroup: [Exercise]] {
        let filtered = searchText.isEmpty
            ? ExerciseLibrary.all
            : ExerciseLibrary.all.filter { $0.name.localizedCaseInsensitiveContains(searchText) }

        return Dictionary(grouping: filtered) { $0.muscleGroup }
    }

    private let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            Color.primaryBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(MuscleGroup.allCases, id: \.self) { group in
                        if let exercises = filteredExercisesByMuscleGroup[group], !exercises.isEmpty {
                            Text(group.displayName)
                                .font(.title3)
                                .bold()
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal)

                            LazyVGrid(columns: gridColumns, spacing: 16) {
                                ForEach(exercises) { exercise in
                                    ExerciseCard(exercise: exercise) {
                                        onSelect(exercise)
                                        dismiss()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("Add Exercise")
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search exercises"
        )
    }
}

fileprivate struct ExerciseCard: View {
    let exercise: Exercise
    let onTap: () -> Void

    var imageName: String {
        ExerciseImageMapper.imageMap[exercise.name] ?? "defaultgymCard"
    }

    // Calculate square size based on screen width and spacing
    private var cardSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 16 * 3 // padding + inter-card spacing
        return (screenWidth - spacing) / 2
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                // Full image with crop to fit
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cardSize, height: cardSize)
                    .clipped()

                // Overlay text
                Text(exercise.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                    .padding(8)
            }
            .frame(width: cardSize, height: cardSize)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
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
        "Burpees": "burpeesCard",
        "Mountain Climbers": "mountainclimberCard",
        "Box Jumps": "boxjumpCard",
        "Rowing Machine": "rowmachineCard",
        "Stair Climber": "stairclimberCard",
        "Walking": "walkingCard",
        "Elliptical": "ellipticalCard",
        "High Knees": "highkneesCard",
        "Jumping Jacks": "cardiogymCard",
        "Battle Ropes": "battleropesCard",
        "Shadow Boxing": "shadowboxingCard",
        "Sled Push": "sledpushCard",
        
        "Bench Press": "benchpressCard",
        "Incline Bench Press": "inclinebenchCard",
        "Dumbbell Press": "dumbellpressCard",
        "Push-ups": "pushupCard",
        "Weighted Push-ups": "weightedpushupCard",
        "Pull-ups": "pullupCard",
        "Weighted Pull-ups": "weightedpullupCard",
        "Chest Fly": "chestflyCard",
        "Cable Crossover": "cablecrossCard",
        "Squat": "squatCard",
        "Front Squat": "squatCard",
        "Goblet Squat": "gobletsquatCard",
        "Leg Extension": "legextCard",
        "Leg Curl": "legcurlCard",
        "Leg Press": "legpressCard",
        "Deadlift": "deadliftCard",
        "Romanian Deadlift": "deadliftCard",
        "Sumo Deadlift": "sumodeadliftCard",
        "Shoulder Press": "shoulderpressCard",
        "Lateral Raises": "latraiseCard",
        "Barbell Row": "barbellrowCard",
        "Dumbbell Row": "dumbellrowCard",
        "Lat Pulldown": "latpulldownCard",
        "Face Pull": "facepullCard",
        "Tricep Pushdown": "triceppushdownCard",
        "Skull Crushers": "skullcrusherCard",
        "Overhead Extension": "overheadextCard",
        "Barbell Curl": "barbellcurlCard",
        "Hammer Curl": "hammercurlCard",
        "Cable Curl": "cablecurlCard",
        "Preacher Curl": "preachercurlCard",
        "Hip Thrust": "hipthrustCard",
        "Calf Raises": "calfraiseCard",
        "Seated Calf Raise": "seatedcalfraisesCard",
        
        "Plank": "plankCard",
        "Side Plank": "sideplankCard",
        "Wall Sit": "wallsitCard",
        "Hollow Body Hold": "hollowbodyholdCard",
        "Leg Lifts": "legraiseCard",
        "Bicycle Crunches": "bicyclecrunchCard",
        "Superman Hold": "supermanCard",
        "V-Ups": "v-upCard",
        "Flutter Kicks": "flutterCard",
        "Toe Touches": "toetouchCard",
        "Russian Twists": "russiantwistCard",
        "Seated Knee Tucks": "kneetuckCard",
        "Cable Crunches": "cablecrunchCard",
        "Hanging Leg Raises": "hanglegraiseCard"
    ]
}
