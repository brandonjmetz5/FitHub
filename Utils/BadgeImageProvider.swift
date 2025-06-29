//
//  BadgeImageProvider.swift
//  FitHub
//
//  Created by brandon metz on 6/26/25.
//

import Foundation
import SwiftUI

struct BadgeImageProvider {
    static func imageName(for badgeType: String, tier: String) -> String {
        let key = "\(badgeType)_\(tier)".lowercased()
        let validImageNames = Bundle.main.paths(forResourcesOfType: "PNG", inDirectory: nil)
            .map { URL(fileURLWithPath: $0).lastPathComponent.lowercased() }

        if validImageNames.contains("\(key).png") {
            return key // use actual badge image
        } else {
            return "badge_default" // fallback image
        }
    }
}
