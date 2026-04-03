//
//  AppStorage.swift
//  133DradigoxBorsexslan
//

import Combine
import Foundation

struct Achievement: Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String

    static let allDefinitions: [Achievement] = [
        Achievement(id: "first_finish", title: "First Finish", detail: "Complete any challenge once."),
        Achievement(id: "ten_stars", title: "Constellation", detail: "Collect 10 stars across challenges."),
        Achievement(id: "easy_perfect_row", title: "Easy Dominance", detail: "Earn 3 stars on every Easy challenge."),
        Achievement(id: "all_activities", title: "All-Rounder", detail: "Earn at least one star in each activity."),
        Achievement(id: "hard_unlocked_play", title: "Elite Trial", detail: "Complete any Hard challenge with a star."),
        Achievement(id: "marathon_speed", title: "Swift Stride", detail: "Finish Virtual Marathon under par on Normal or Hard."),
        Achievement(id: "precision_sharpshooter", title: "Sharpshooter", detail: "Reach 90% accuracy on Precision Pass."),
        Achievement(id: "keeper_wall", title: "The Wall", detail: "Save 90% or more in Goalkeeper Reflex."),
    ]
}

@MainActor
final class GameProgressStore: ObservableObject {
    private let defaults: UserDefaults

    private enum Key {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalPlaySeconds = "totalPlaySeconds"
        static let totalActivitiesPlayed = "totalActivitiesPlayed"
        static let acknowledgedAchievements = "acknowledgedAchievements"
        static let bestMarathonEasy = "bestMarathonEasy"
        static let bestMarathonNormal = "bestMarathonNormal"
        static let bestMarathonHard = "bestMarathonHard"
        static let bestPrecisionEasy = "bestPrecisionEasy"
        static let bestPrecisionNormal = "bestPrecisionNormal"
        static let bestPrecisionHard = "bestPrecisionHard"
        static let bestKeeperEasy = "bestKeeperEasy"
        static let bestKeeperNormal = "bestKeeperNormal"
        static let bestKeeperHard = "bestKeeperHard"
    }

    @Published private(set) var hasSeenOnboarding: Bool
    @Published private(set) var totalPlaySeconds: TimeInterval
    @Published private(set) var totalActivitiesPlayed: Int

    private var acknowledgedAchievementIds: Set<String>

    static let challengeOrder: [ChallengeSlot] = [
        ChallengeSlot(activity: .virtualMarathon, difficulty: .easy),
        ChallengeSlot(activity: .precisionPass, difficulty: .easy),
        ChallengeSlot(activity: .goalkeeperReflex, difficulty: .easy),
        ChallengeSlot(activity: .virtualMarathon, difficulty: .normal),
        ChallengeSlot(activity: .precisionPass, difficulty: .normal),
        ChallengeSlot(activity: .goalkeeperReflex, difficulty: .normal),
        ChallengeSlot(activity: .virtualMarathon, difficulty: .hard),
        ChallengeSlot(activity: .precisionPass, difficulty: .hard),
        ChallengeSlot(activity: .goalkeeperReflex, difficulty: .hard),
    ]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Key.hasSeenOnboarding)
        totalPlaySeconds = defaults.double(forKey: Key.totalPlaySeconds)
        totalActivitiesPlayed = Int(defaults.integer(forKey: Key.totalActivitiesPlayed))
        if let data = defaults.data(forKey: Key.acknowledgedAchievements),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            acknowledgedAchievementIds = Set(decoded)
        } else {
            acknowledgedAchievementIds = []
        }
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
        defaults.set(true, forKey: Key.hasSeenOnboarding)
    }

    func stars(for slot: ChallengeSlot) -> Int {
        defaults.integer(forKey: starsKey(slot))
    }

    func isUnlocked(_ slot: ChallengeSlot) -> Bool {
        guard let idx = Self.challengeOrder.firstIndex(of: slot) else { return false }
        if idx == 0 { return true }
        let prev = Self.challengeOrder[idx - 1]
        return stars(for: prev) >= 1
    }

    func nextSlot(after slot: ChallengeSlot) -> ChallengeSlot? {
        guard let idx = Self.challengeOrder.firstIndex(of: slot),
              idx + 1 < Self.challengeOrder.count else { return nil }
        return Self.challengeOrder[idx + 1]
    }

    func totalStarsCollected() -> Int {
        Self.challengeOrder.reduce(0) { $0 + stars(for: $1) }
    }

    func recordCompletion(outcome: ActivityOutcome) {
        guard outcome.won else { return }
        let slot = outcome.slot
        let previous = stars(for: slot)
        let newValue = max(previous, outcome.starsEarned)
        defaults.set(newValue, forKey: starsKey(slot))

        totalActivitiesPlayed += 1
        defaults.set(totalActivitiesPlayed, forKey: Key.totalActivitiesPlayed)

        totalPlaySeconds += outcome.durationSeconds
        defaults.set(totalPlaySeconds, forKey: Key.totalPlaySeconds)

        updateBests(outcome: outcome)
        objectWillChange.send()
    }

    private func updateBests(outcome: ActivityOutcome) {
        switch outcome.slot.activity {
        case .virtualMarathon:
            let key = marathonBestKey(outcome.slot.difficulty)
            let current = defaults.double(forKey: key)
            if current == 0 || outcome.durationSeconds < current {
                defaults.set(outcome.durationSeconds, forKey: key)
            }
        case .precisionPass:
            let key = precisionBestKey(outcome.slot.difficulty)
            let current = defaults.double(forKey: key)
            if outcome.accuracyPercent > current {
                defaults.set(outcome.accuracyPercent, forKey: key)
            }
        case .goalkeeperReflex:
            let key = keeperBestKey(outcome.slot.difficulty)
            let current = defaults.double(forKey: key)
            if outcome.accuracyPercent > current {
                defaults.set(outcome.accuracyPercent, forKey: key)
            }
        }
    }

    func bestMarathonTime(for difficulty: Difficulty) -> TimeInterval? {
        let v = defaults.double(forKey: marathonBestKey(difficulty))
        return v > 0 ? v : nil
    }

    func bestPrecisionAccuracy(for difficulty: Difficulty) -> Double? {
        let v = defaults.double(forKey: precisionBestKey(difficulty))
        return v > 0 ? v : nil
    }

    func bestKeeperRate(for difficulty: Difficulty) -> Double? {
        let v = defaults.double(forKey: keeperBestKey(difficulty))
        return v > 0 ? v : nil
    }

    func resetAllProgress() {
        let keys = defaults.dictionaryRepresentation().keys
        for key in keys where key.hasPrefix("stars_") || key.hasPrefix("slot_") {
            defaults.removeObject(forKey: key)
        }
        for k in [
            Key.hasSeenOnboarding, Key.totalPlaySeconds, Key.totalActivitiesPlayed,
            Key.acknowledgedAchievements,
            Key.bestMarathonEasy, Key.bestMarathonNormal, Key.bestMarathonHard,
            Key.bestPrecisionEasy, Key.bestPrecisionNormal, Key.bestPrecisionHard,
            Key.bestKeeperEasy, Key.bestKeeperNormal, Key.bestKeeperHard,
        ] {
            defaults.removeObject(forKey: k)
        }
        hasSeenOnboarding = false
        totalPlaySeconds = 0
        totalActivitiesPlayed = 0
        acknowledgedAchievementIds = []
        objectWillChange.send()
        NotificationCenter.default.post(name: .progressDidReset, object: nil)
    }

    func newlyUnlockedAchievements() -> [Achievement] {
        let unlocked = Set(unlockedAchievementDefinitions().map(\.id))
        let fresh = unlocked.subtracting(acknowledgedAchievementIds)
        return Achievement.allDefinitions.filter { fresh.contains($0.id) }
    }

    func acknowledgeNewAchievements() {
        acknowledgedAchievementIds = Set(unlockedAchievementDefinitions().map(\.id))
        if let data = try? JSONEncoder().encode(Array(acknowledgedAchievementIds)) {
            defaults.set(data, forKey: Key.acknowledgedAchievements)
        }
    }

    func unlockedAchievementDefinitions() -> [Achievement] {
        Achievement.allDefinitions.filter { isSatisfied(achievementId: $0.id) }
    }

    private func isSatisfied(achievementId: String) -> Bool {
        switch achievementId {
        case "first_finish":
            return totalActivitiesPlayed >= 1
        case "ten_stars":
            return totalStarsCollected() >= 10
        case "easy_perfect_row":
            let easySlots = Self.challengeOrder.filter { $0.difficulty == .easy }
            return easySlots.allSatisfy { stars(for: $0) >= 3 }
        case "all_activities":
            return ActivityKind.allCases.allSatisfy { act in
                Self.challengeOrder.contains { $0.activity == act && stars(for: $0) >= 1 }
            }
        case "hard_unlocked_play":
            return Self.challengeOrder.filter { $0.difficulty == .hard }.contains { stars(for: $0) >= 1 }
        case "marathon_speed":
            let normal = bestMarathonTime(for: .normal) ?? .infinity
            let hard = bestMarathonTime(for: .hard) ?? .infinity
            let parN: TimeInterval = 48
            let parH: TimeInterval = 38
            return normal < parN || hard < parH
        case "precision_sharpshooter":
            return Difficulty.allCases.contains { diff in
                (bestPrecisionAccuracy(for: diff) ?? 0) >= 90
            }
        case "keeper_wall":
            return Difficulty.allCases.contains { diff in
                (bestKeeperRate(for: diff) ?? 0) >= 90
            }
        default:
            return false
        }
    }

    private func starsKey(_ slot: ChallengeSlot) -> String {
        "stars_\(slot.activity.rawValue)_\(slot.difficulty.rawValue)"
    }

    private func marathonBestKey(_ d: Difficulty) -> String {
        switch d {
        case .easy: return Key.bestMarathonEasy
        case .normal: return Key.bestMarathonNormal
        case .hard: return Key.bestMarathonHard
        }
    }

    private func precisionBestKey(_ d: Difficulty) -> String {
        switch d {
        case .easy: return Key.bestPrecisionEasy
        case .normal: return Key.bestPrecisionNormal
        case .hard: return Key.bestPrecisionHard
        }
    }

    private func keeperBestKey(_ d: Difficulty) -> String {
        switch d {
        case .easy: return Key.bestKeeperEasy
        case .normal: return Key.bestKeeperNormal
        case .hard: return Key.bestKeeperHard
        }
    }
}
