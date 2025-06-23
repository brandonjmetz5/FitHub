//
//  UserProfile.swift
//  FitHub
//
//  Created by brandon metz on 6/22/25.
//

import Foundation
import FirebaseFirestoreSwift

enum ActivityLevel: String, CaseIterable, Codable, Identifiable {
    case sedentary    = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case veryActive   = "Very Active"
    case extraActive  = "Extra Active"
    
    var id: String { rawValue }
    
    var factor: Double {
        switch self {
        case .sedentary:         return 1.2
        case .lightlyActive:     return 1.375
        case .moderatelyActive:  return 1.55
        case .veryActive:        return 1.725
        case .extraActive:       return 1.9
        }
    }
}

enum GoalType: String, CaseIterable, Codable, Identifiable {
    case loseWeight   = "Lose Weight"
    case maintainWeight = "Maintain Weight"
    case gainWeight   = "Gain Weight"
    
    var id: String { rawValue }
}

struct MacroSplit: Codable, Equatable {
    var proteinRatio: Double
    var carbsRatio: Double
    var fatRatio: Double
}

struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?    // Firestore will set this to uid
    var age: Int
    var sex: String                // e.g. "Male" or "Female"
    var heightCm: Double
    var weightKg: Double
    var activityLevel: ActivityLevel
    var goal: GoalType
    var weeklyRateLbs: Double      // e.g. 0.5 lbs/week
    var macroSplit: MacroSplit
    
    // Computed properties (not stored)
    var bmr: Double {
        // Mifflin-St Jeor:
        // Men: 10*kg + 6.25*cm - 5*age + 5
        // Women: 10*kg + 6.25*cm - 5*age - 161
        let s = sex.lowercased().contains("male") ? 5.0 : -161.0
        return 10 * weightKg + 6.25 * heightCm - 5 * Double(age) + s
    }
    
    var tdee: Double {
        bmr * activityLevel.factor
    }
    
    var calorieTarget: Double {
        // Convert lbs/week to kcal/day (1 lb ≈ 3500 kcal)
        let adjust = (weeklyRateLbs * 3500) / 7
        switch goal {
        case .loseWeight:      return tdee - adjust
        case .maintainWeight:  return tdee
        case .gainWeight:      return tdee + adjust
        }
    }
    
    var proteinTarget: Double {
        calorieTarget * macroSplit.proteinRatio / 4
    }
    var carbsTarget: Double {
        calorieTarget * macroSplit.carbsRatio / 4
    }
    var fatTarget: Double {
        calorieTarget * macroSplit.fatRatio / 9
    }
}
