//
//  WorkoutTemplate.swift
//  FitHub
//
//  Created by brandon metz on 6/23/25.
//

import Foundation
import FirebaseFirestoreSwift

struct WorkoutTemplate: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var isPreset: Bool
    var userId: String?
    var exercises: [Exercise]
}
