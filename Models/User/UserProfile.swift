//
//  UserProfile.swift
//  FitHub
//
//  Created by brandon metz on 6/22/25.
//

import Foundation
import FirebaseFirestoreSwift

/// Activity multipliers for TDEE calculation
enum ActivityLevel: String, CaseIterable, Codable, Identifiable {
    case sedentary       = "Sedentary"
    case lightlyActive   = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case veryActive      = "Very Active"
    case extraActive     = "Extra Active"

    var id: String { rawValue }
    var factor: Double {
        switch self {
        case .sedentary:        return 1.2
        case .lightlyActive:    return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive:       return 1.725
        case .extraActive:      return 1.9
        }
    }
}

/// Weight goal types for calorie adjustments
enum GoalType: String, CaseIterable, Codable, Identifiable {
    case loseWeight       = "Lose Weight"
    case maintainWeight   = "Maintain Weight"
    case gainWeight       = "Gain Weight"

    var id: String { rawValue }
}

/// Macro-nutrient ratios (protein, carbs, fat)
struct MacroSplit: Codable, Equatable {
    var proteinRatio: Double
    var carbsRatio: Double
    var fatRatio: Double
}

/// User profile containing personal data, starting/goal weights in US units, and computed targets
struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?    // Firestore will set this to uid
    var age: Int
    var sex: String                // "Male" or "Female"
    var heightFeet: Double         // US units
    var heightInches: Double       // US units
    var startWeightLb: Double      // US units
    var goalWeightLb: Double       // US units
    var activityLevel: ActivityLevel
    var goal: GoalType
    var weeklyRateLbs: Double      // e.g. 0.5 lbs/week
    var macroSplit: MacroSplit

    // MARK: - Internal conversions

    /// Height in centimeters
    private var heightCm: Double {
        (heightFeet * 12 + heightInches) * 2.54
    }

    /// Weight in kilograms
    private var weightKg: Double {
        startWeightLb / 2.20462
    }

    // MARK: - Computed properties (not stored)

    /// Basal Metabolic Rate (Mifflin–St Jeor equation)
    var bmr: Double {
        let s: Double
        switch sex.lowercased() {
        case "male":
            s =  5.0
        case "female":
            s = -161.0
        default:
            s =   0.0
        }
        return 10 * weightKg
             + 6.25 * heightCm
             - 5 * Double(age)
             + s
    }

    /// Total Daily Energy Expenditure
    var tdee: Double {
        bmr * activityLevel.factor
    }

    /// Daily calorie target adjusted by goal and weekly rate
    var calorieTarget: Double {
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

    /// Carbs target in grams (4 kcal per gram)
    var carbsTarget: Double {
        calorieTarget * macroSplit.carbsRatio / 4
    }

    /// Fat target in grams (9 kcal per gram)
    var fatTarget: Double {
        calorieTarget * macroSplit.fatRatio / 9
    }
}
