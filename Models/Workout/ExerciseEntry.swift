//
//  ExerciseEntry.swift
//  FitHub
//
//  Created by brandon metz on 6/23/25.
//

import Foundation

struct ExerciseEntry: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var exercise: Exercise
    var sets: Int
    var reps: Int
    var weight: Double?
    var duration: Double?    // e.g. seconds for cardio
}
