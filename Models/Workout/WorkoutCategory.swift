//
//  WorkoutCategory.swift
//  FitHub
//
//  Created by brandon metz on 6/23/25.
//

import Foundation

/// High-level grouping for your exercises
enum WorkoutCategory: String, Codable, Hashable {
    case upperBody
    case lowerBody
    case fullBody
    case core
    case cardio
    // add more categories as needed
}
