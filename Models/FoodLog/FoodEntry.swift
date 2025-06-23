//
//  FoodEntry.swift
//  FitHub
//
//  Created by brandon metz on 6/22/25.
//

import Foundation

enum MealType: String, Codable, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch     = "Lunch"
    case dinner    = "Dinner"
    case snack     = "Snack"

    var id: String { rawValue }
}

struct FoodEntry: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var brand: String?
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
    var quantity: Double
    var unit: String
    var loggedAt: Date = Date()
    var meal: MealType = .snack
}
