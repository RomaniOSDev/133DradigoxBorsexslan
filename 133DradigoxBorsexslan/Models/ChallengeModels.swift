//
//  ChallengeModels.swift
//  133DradigoxBorsexslan
//

import Foundation

enum ActivityKind: String, CaseIterable, Codable, Hashable {
    case virtualMarathon
    case precisionPass
    case goalkeeperReflex

    var displayTitle: String {
        switch self {
        case .virtualMarathon: return "Virtual Marathon"
        case .precisionPass: return "Precision Pass"
        case .goalkeeperReflex: return "Goalkeeper Reflex"
        }
    }

    var shortLabel: String {
        switch self {
        case .virtualMarathon: return "Marathon"
        case .precisionPass: return "Pass"
        case .goalkeeperReflex: return "Saves"
        }
    }
}

enum Difficulty: String, CaseIterable, Codable, Hashable {
    case easy
    case normal
    case hard

    var displayTitle: String {
        switch self {
        case .easy: return "Easy"
        case .normal: return "Normal"
        case .hard: return "Hard"
        }
    }
}

struct ChallengeSlot: Hashable, Codable {
    let activity: ActivityKind
    let difficulty: Difficulty
}

struct ActivityOutcome: Hashable {
    let slot: ChallengeSlot
    let starsEarned: Int
    let durationSeconds: TimeInterval
    let accuracyPercent: Double
    let won: Bool
}
