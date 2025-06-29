//
//  WorkoutCategory.swift
//  FitHub
//
//  Created by brandon metz on 6/23/25.
//

import Foundation

/// High-level grouping for your exercises
enum MuscleGroup: String, Codable, Hashable, CaseIterable {
    case chest
    case triceps
    case biceps
    case shoulders
    case traps
    case back
    case forearms
    case quads
    case glutes
    case calves
    case core
    case cardio

    var displayName: String {
        switch self {
        case .chest: return "🫀 Chest"
        case .triceps: return "🔧 Triceps"
        case .biceps: return "💪 Biceps"
        case .shoulders: return "🏋️ Shoulders"
        case .traps: return "📦 Traps"
        case .back: return "🪵 Back"
        case .forearms: return "🖐️ Forearms"
        case .quads: return "🦿 Quads"
        case .glutes: return "🍑 Glutes"
        case .calves: return "🦶 Calves"
        case .core: return "🧱 Core"
        case .cardio: return "🏃 Cardio"
            
        }
    }
}


