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
        Exercise(name: "Running", inputType: .cardio, category: .cardio),
        Exercise(name: "Cycling", inputType: .cardio, category: .cardio),
        Exercise(name: "Jump Rope", inputType: .cardio, category: .cardio),
        Exercise(name: "Burpees", inputType: .cardio, category: .fullBody),
        Exercise(name: "Mountain Climbers", inputType: .cardio, category: .core),
        Exercise(name: "Box Jumps", inputType: .cardio, category: .lowerBody),
        Exercise(name: "Rowing Machine", inputType: .cardio, category: .fullBody),
        Exercise(name: "Stair Climber", inputType: .cardio, category: .fullBody),
        Exercise(name: "Walking", inputType: .cardio, category: .cardio),
        Exercise(name: "Treadmill", inputType: .cardio, category: .cardio),
        Exercise(name: "Elliptical", inputType: .cardio, category: .cardio),
        Exercise(name: "High Knees", inputType: .cardio, category: .cardio),
        Exercise(name: "Jumping Jacks", inputType: .cardio, category: .cardio),
        Exercise(name: "Battle Ropes", inputType: .cardio, category: .upperBody),
        Exercise(name: "Shadow Boxing", inputType: .cardio, category: .upperBody),
        Exercise(name: "Swimming", inputType: .cardio, category: .fullBody),
        Exercise(name: "Hiking", inputType: .cardio, category: .cardio),
        Exercise(name: "Dance Cardio", inputType: .cardio, category: .fullBody),
        Exercise(name: "Sled Push", inputType: .cardio, category: .fullBody),
        
        // Strength
        Exercise(name: "Bench Press", inputType: .strength, category: .upperBody),
        Exercise(name: "Incline Bench Press", inputType: .strength, category: .upperBody),
        Exercise(name: "Dumbbell Press", inputType: .strength, category: .upperBody),
        Exercise(name: "Push-ups", inputType: .strength, category: .upperBody),
        Exercise(name: "Weighted Push-ups", inputType: .strength, category: .upperBody),
        Exercise(name: "Pull-ups", inputType: .strength, category: .upperBody),
        Exercise(name: "Weighted Pull-ups", inputType: .strength, category: .upperBody),
        Exercise(name: "Chest Fly", inputType: .strength, category: .upperBody),
        Exercise(name: "Cable Crossover", inputType: .strength, category: .upperBody),
        Exercise(name: "Squat", inputType: .strength, category: .lowerBody),
        Exercise(name: "Front Squat", inputType: .strength, category: .lowerBody),
        Exercise(name: "Goblet Squat", inputType: .strength, category: .lowerBody),
        Exercise(name: "Leg Extension", inputType: .strength, category: .lowerBody),
        Exercise(name: "Leg Curl", inputType: .strength, category: .lowerBody),
        Exercise(name: "Leg Press", inputType: .strength, category: .lowerBody),
        Exercise(name: "Deadlift", inputType: .strength, category: .lowerBody),
        Exercise(name: "Romanian Deadlift", inputType: .strength, category: .lowerBody),
        Exercise(name: "Sumo Deadlift", inputType: .strength, category: .lowerBody),
        Exercise(name: "Shoulder Press", inputType: .strength, category: .upperBody),
        Exercise(name: "Lateral Raises", inputType: .strength, category: .upperBody),
        Exercise(name: "Barbell Row", inputType: .strength, category: .upperBody),
        Exercise(name: "Dumbbell Row", inputType: .strength, category: .upperBody),
        Exercise(name: "Lat Pulldown", inputType: .strength, category: .upperBody),
        Exercise(name: "Face Pull", inputType: .strength, category: .upperBody),
        Exercise(name: "Tricep Pushdown", inputType: .strength, category: .upperBody),
        Exercise(name: "Skull Crushers", inputType: .strength, category: .upperBody),
        Exercise(name: "Overhead Extension", inputType: .strength, category: .upperBody),
        Exercise(name: "Barbell Curl", inputType: .strength, category: .upperBody),
        Exercise(name: "Hammer Curl", inputType: .strength, category: .upperBody),
        Exercise(name: "Cable Curl", inputType: .strength, category: .upperBody),
        Exercise(name: "Preacher Curl", inputType: .strength, category: .upperBody),
        Exercise(name: "Hip Thrust", inputType: .strength, category: .lowerBody),
        Exercise(name: "Calf Raises", inputType: .strength, category: .lowerBody),
        Exercise(name: "Seated Calf Raise", inputType: .strength, category: .lowerBody),
        
        // Core
        Exercise(name: "Plank", inputType: .strength, category: .core),
        Exercise(name: "Side Plank", inputType: .strength, category: .core),
        Exercise(name: "Wall Sit", inputType: .strength, category: .lowerBody),
        Exercise(name: "Hollow Body Hold", inputType: .strength, category: .core),
        Exercise(name: "Leg Lifts", inputType: .strength, category: .core),
        Exercise(name: "Bicycle Crunches", inputType: .strength, category: .core),
        Exercise(name: "Superman Hold", inputType: .strength, category: .core),
        Exercise(name: "V-Ups", inputType: .strength, category: .core),
        Exercise(name: "Flutter Kicks", inputType: .strength, category: .core),
        Exercise(name: "Toe Touches", inputType: .strength, category: .core),
        Exercise(name: "Russian Twists", inputType: .strength, category: .core),
        Exercise(name: "Seated Knee Tucks", inputType: .strength, category: .core),
        Exercise(name: "Cable Crunches", inputType: .strength, category: .core),
        Exercise(name: "Hanging Leg Raises", inputType: .strength, category: .core)
    ]
}
