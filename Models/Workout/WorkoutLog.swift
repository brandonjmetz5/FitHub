//
//  WorkoutLog.swift
//  FitHub
//
//  Created by brandon metz on 6/23/25.
//

import Foundation
import FirebaseFirestoreSwift

struct WorkoutLog: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var date: Date = Date()
    var templateID: String?
    var performedExercises: [ExerciseEntry]
}
