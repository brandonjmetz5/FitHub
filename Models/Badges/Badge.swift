//
//  Badge.swift
//  FitHub
//
//  Created by brandon metz on 6/26/25.
//

import Foundation

//struct Badge: Identifiable, Codable {
//    let id: String // this should match the document ID in Firestore
//    let type: BadgeType
//    let tier: BadgeTier
//    let timesEarnedByTier: [BadgeTier: Int]
//    let lastAwarded: Date?
//
//    enum CodingKeys: String, CodingKey {
//        case type, tier, timesEarnedByTier, lastAwarded
//    }
//
//    // Use this to ensure Firestore document ID is available as `id`
//    init(id: String, type: BadgeType, tier: BadgeTier, timesEarnedByTier: [BadgeTier: Int], lastAwarded: Date? = nil) {
//        self.id = id
//        self.type = type
//        self.tier = tier
//        self.timesEarnedByTier = timesEarnedByTier
//        self.lastAwarded = lastAwarded
//    }
//
//    // Optional convenience for getting times earned for a specific tier
//    func timesEarned(for tier: BadgeTier) -> Int {
//        return timesEarnedByTier[tier] ?? 0
//    }
//}
//
