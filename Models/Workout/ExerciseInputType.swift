//
//  ExerciseInputType.swift
//  FitHub
//
//  Created by brandon metz on 6/23/25.
//

import Foundation

/// Controls how the user records this exercise
enum ExerciseInputType: String, Codable, Hashable {
    case strength    // reps, sets, weight
    case cardio      // duration, distance, etc.
}
