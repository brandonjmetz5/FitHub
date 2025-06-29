//
//  Exercise.swift
//  FitHub
//
//  Created by brandon metz on 6/23/25.
//


import Foundation
import FirebaseFirestoreSwift

/// Represents an exercise with unique identifier, name, input type, and category.
struct Exercise: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var inputType: ExerciseInputType
    var muscleGroup: MuscleGroup

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case inputType
        case muscleGroup
    }
}
