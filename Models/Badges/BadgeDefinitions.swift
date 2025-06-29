//
//  BadgeDefinitions.swift
//  FitHub
//
//  Created by brandon metz on 6/26/25.
//

import Foundation

/// All badge identifiers in the system.
public enum BadgeType: String, CaseIterable, Codable, Identifiable {
    case proteinWarrior
    case carbConqueror
    case fatFighter
    case calorieCommander
    case macroMaestro
    case dailyLogger
    case mealMaestro
    case monthlyMarathoner
    case streakMaster
    case workoutInitiate
    case strengthBuilder
    case cardioChamp
    case weighInEnthusiast
    case scaleSurpasser
    case bigGains
    case weightConsistency
    case badgeCollector
    case masterOfMetrics

    public var id: String { rawValue }
}

/// Monthly thresholds for each badge (all activity counts reset on the 1st).
public struct BadgeThresholds {
    public static let values: [BadgeType: [BadgeTier: Int]] = [
        .proteinWarrior:     [.bronze: 5,  .silver: 10, .gold: 15, .elite: 20, .platinum: 25],
        .carbConqueror:      [.bronze: 5,  .silver: 10, .gold: 15, .elite: 20, .platinum: 25],
        .fatFighter:         [.bronze: 5,  .silver: 10, .gold: 15, .elite: 20, .platinum: 25],
        .calorieCommander:   [.bronze: 5,  .silver: 10, .gold: 15, .elite: 20, .platinum: 25],
        .macroMaestro:       [.bronze: 3,  .silver: 7,  .gold: 10, .elite: 15, .platinum: 20],
        .dailyLogger:        [.bronze: 5,  .silver: 10, .gold: 15, .elite: 20, .platinum: 25],
        .mealMaestro:        [.bronze: 3,  .silver: 7,  .gold: 10, .elite: 15, .platinum: 20],
        .monthlyMarathoner:  [.bronze: 10, .silver: 15, .gold: 20, .elite: 25, .platinum: Calendar.current.daysInCurrentMonth()],
        .streakMaster:       [.bronze: 3,  .silver: 7,  .gold: 14, .elite: 21, .platinum: 28],
        .workoutInitiate:    [.bronze: 5,  .silver: 10, .gold: 15, .elite: 20, .platinum: 25],
        .strengthBuilder:    [.bronze: 5,  .silver: 10, .gold: 15, .elite: 20, .platinum: 25],
        .cardioChamp:        [.bronze: 5,  .silver: 10, .gold: 15, .elite: 20, .platinum: 25],
        .weighInEnthusiast:  [.bronze: 5,  .silver: 10, .gold: 15, .elite: 20, .platinum: 25],
        .scaleSurpasser:     [.bronze: 3,  .silver: 7,  .gold: 14, .elite: 21, .platinum: 28],
        .bigGains:           [.bronze: 3,  .silver: 7,  .gold: 14, .elite: 21, .platinum: 28],
        .weightConsistency:  [.bronze: 1,  .silver: 2,  .gold: 3,  .elite: 4,  .platinum: 5],
        .badgeCollector:     [.bronze: 4,  .silver: 8,  .gold: 12, .elite: 16, .platinum: 18],
        .masterOfMetrics:    [.gold: 15,  .elite: 15, .platinum: 15]
    ]
}

extension Calendar {
    /// Number of days in the current calendar month.
    func daysInCurrentMonth() -> Int {
        guard let range = range(of: .day, in: .month, for: Date()) else {
            return 30
        }
        return range.count
    }
}
