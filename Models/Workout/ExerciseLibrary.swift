//
//  ExerciseLibrary.swift
//  FitHub
//
//  Created by brandon metz on 6/23/25.
//

import Foundation

/// A master list of all exercises available in the app.
struct ExerciseLibrary {
    static let all: [Exercise] = [
        // Cardio
        Exercise(name: "Running", inputType: .cardio, muscleGroup: .cardio),
        Exercise(name: "Cycling", inputType: .cardio, muscleGroup: .cardio),
        Exercise(name: "Jump Rope", inputType: .cardio, muscleGroup: .cardio),
        Exercise(name: "Burpees", inputType: .cardio, muscleGroup: .cardio),
        Exercise(name: "Mountain Climbers", inputType: .cardio, muscleGroup: .cardio),
        Exercise(name: "Box Jumps", inputType: .cardio, muscleGroup: .cardio),
        Exercise(name: "Rowing Machine", inputType: .cardio, muscleGroup: .cardio),
        Exercise(name: "Stair Climber", inputType: .cardio, muscleGroup: .cardio),
        Exercise(name: "Walking", inputType: .cardio, muscleGroup: .cardio),
        Exercise(name: "Elliptical", inputType: .cardio, muscleGroup: .cardio),
        Exercise(name: "High Knees", inputType: .cardio, muscleGroup: .cardio),
        Exercise(name: "Jumping Jacks", inputType: .cardio, muscleGroup: .cardio),
        Exercise(name: "Battle Ropes", inputType: .cardio, muscleGroup: .shoulders),
        Exercise(name: "Shadow Boxing", inputType: .cardio, muscleGroup: .traps),
        Exercise(name: "Sled Push", inputType: .cardio, muscleGroup: .quads),

        // Chest
        Exercise(name: "Bench Press", inputType: .strength, muscleGroup: .chest),
        Exercise(name: "Incline Bench Press", inputType: .strength, muscleGroup: .chest),
        Exercise(name: "Dumbbell Press", inputType: .strength, muscleGroup: .chest),
        Exercise(name: "Push-ups", inputType: .strength, muscleGroup: .chest),
        Exercise(name: "Weighted Push-ups", inputType: .strength, muscleGroup: .chest),
        Exercise(name: "Chest Fly", inputType: .strength, muscleGroup: .chest),
        Exercise(name: "Cable Crossover", inputType: .strength, muscleGroup: .chest),

        // Back
        Exercise(name: "Pull-ups", inputType: .strength, muscleGroup: .back),
        Exercise(name: "Weighted Pull-ups", inputType: .strength, muscleGroup: .back),
        Exercise(name: "Barbell Row", inputType: .strength, muscleGroup: .back),
        Exercise(name: "Dumbbell Row", inputType: .strength, muscleGroup: .back),
        Exercise(name: "Lat Pulldown", inputType: .strength, muscleGroup: .back),
        Exercise(name: "Deadlift", inputType: .strength, muscleGroup: .back),
        Exercise(name: "Romanian Deadlift", inputType: .strength, muscleGroup: .back),
        Exercise(name: "Sumo Deadlift", inputType: .strength, muscleGroup: .back),
        Exercise(name: "Face Pull", inputType: .strength, muscleGroup: .traps),

        // Shoulders
        Exercise(name: "Shoulder Press", inputType: .strength, muscleGroup: .shoulders),
        Exercise(name: "Lateral Raises", inputType: .strength, muscleGroup: .shoulders),

        // Triceps
        Exercise(name: "Tricep Pushdown", inputType: .strength, muscleGroup: .triceps),
        Exercise(name: "Skull Crushers", inputType: .strength, muscleGroup: .triceps),
        Exercise(name: "Overhead Extension", inputType: .strength, muscleGroup: .triceps),

        // Biceps
        Exercise(name: "Barbell Curl", inputType: .strength, muscleGroup: .biceps),
        Exercise(name: "Hammer Curl", inputType: .strength, muscleGroup: .biceps),
        Exercise(name: "Cable Curl", inputType: .strength, muscleGroup: .biceps),
        Exercise(name: "Preacher Curl", inputType: .strength, muscleGroup: .biceps),

        // Quads
        Exercise(name: "Squat", inputType: .strength, muscleGroup: .quads),
        Exercise(name: "Front Squat", inputType: .strength, muscleGroup: .quads),
        Exercise(name: "Goblet Squat", inputType: .strength, muscleGroup: .quads),
        Exercise(name: "Leg Extension", inputType: .strength, muscleGroup: .quads),
        Exercise(name: "Wall Sit", inputType: .strength, muscleGroup: .quads),

        // Glutes
        Exercise(name: "Leg Curl", inputType: .strength, muscleGroup: .glutes),
        Exercise(name: "Leg Press", inputType: .strength, muscleGroup: .glutes),
        Exercise(name: "Hip Thrust", inputType: .strength, muscleGroup: .glutes),

        // Calves
        Exercise(name: "Calf Raises", inputType: .strength, muscleGroup: .calves),
        Exercise(name: "Seated Calf Raise", inputType: .strength, muscleGroup: .calves),

        // Core
        Exercise(name: "Plank", inputType: .strength, muscleGroup: .core),
        Exercise(name: "Side Plank", inputType: .strength, muscleGroup: .core),
        Exercise(name: "Hollow Body Hold", inputType: .strength, muscleGroup: .core),
        Exercise(name: "Leg Lifts", inputType: .strength, muscleGroup: .core),
        Exercise(name: "Bicycle Crunches", inputType: .strength, muscleGroup: .core),
        Exercise(name: "Superman Hold", inputType: .strength, muscleGroup: .core),
        Exercise(name: "V-Ups", inputType: .strength, muscleGroup: .core),
        Exercise(name: "Flutter Kicks", inputType: .strength, muscleGroup: .core),
        Exercise(name: "Toe Touches", inputType: .strength, muscleGroup: .core),
        Exercise(name: "Russian Twists", inputType: .strength, muscleGroup: .core),
        Exercise(name: "Seated Knee Tucks", inputType: .strength, muscleGroup: .core),
        Exercise(name: "Cable Crunches", inputType: .strength, muscleGroup: .core),
        Exercise(name: "Hanging Leg Raises", inputType: .strength, muscleGroup: .core)
    ]
}
