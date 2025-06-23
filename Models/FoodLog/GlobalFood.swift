//
//  GlobalFood.swift
//  FitHub
//
//  Created by brandon metz on 6/22/25.
//

import Foundation
import FirebaseFirestoreSwift


struct GlobalFood: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var brand: String?
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
    var quantity: Double
    var unit: String

    // Metadata
    var nameKey: String
    var brandKey: String
    var isUserCreated: Bool
    var creatorId: String
    var createdAt: Date

    // Reporting
    var reportCount: Int?
    var isReported: Bool?
}
