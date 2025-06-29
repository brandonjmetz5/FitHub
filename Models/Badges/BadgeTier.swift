//
//  BadgeTier.swift
//  FitHub
//
//  Created by brandon metz on 6/26/25.
//

import Foundation

/// The tier levels a badge can have.
public enum BadgeTier: String, CaseIterable, Codable, Identifiable {
    case none
    case bronze
    case silver
    case gold
    case elite
    case platinum

    /// Conformance to Identifiable
    public var id: String { rawValue }

    /// The next-higher tier, if any
    public var next: BadgeTier? {
        switch self {
        case .none:     return .bronze
        case .bronze:   return .silver
        case .silver:   return .gold
        case .gold:     return .elite
        case .elite:    return .platinum
        case .platinum: return nil
        }
    }
}
