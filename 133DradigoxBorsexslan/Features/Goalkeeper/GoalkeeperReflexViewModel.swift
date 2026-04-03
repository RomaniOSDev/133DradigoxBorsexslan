//
//  GoalkeeperReflexViewModel.swift
//  133DradigoxBorsexslan
//

import Combine
import Foundation
import SwiftUI

final class GoalkeeperReflexViewModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case shotActive
        case betweenShots
        case won
        case lost
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var currentRound: Int = 0
    @Published private(set) var saves: Int = 0
    @Published private(set) var misses: Int = 0
    @Published private(set) var ballProgress: CGFloat = 0
    @Published private(set) var ballNormalizedX: CGFloat = 0.5
    @Published private(set) var decoyShift: CGFloat = 0

    let difficulty: Difficulty
    let totalRounds: Int
    let savesNeeded: Int
    private let shotDuration: TimeInterval
    private let useDecoys: Bool

    private var elapsed: TimeInterval = 0
    private var shotTimer: TimeInterval = 0
    private var reactedThisShot = false
    private var appliedDecoy = false

    init(difficulty: Difficulty) {
        self.difficulty = difficulty
        switch difficulty {
        case .easy:
            totalRounds = 5
            savesNeeded = 3
            shotDuration = 1.85
            useDecoys = false
        case .normal:
            totalRounds = 7
            savesNeeded = 5
            shotDuration = 1.45
            useDecoys = false
        case .hard:
            totalRounds = 10
            savesNeeded = 7
            shotDuration = 1.05
            useDecoys = true
        }
    }

    func startSession() {
        currentRound = 0
        saves = 0
        misses = 0
        ballProgress = 0
        shotTimer = 0
        reactedThisShot = false
        appliedDecoy = false
        decoyShift = 0
        elapsed = 0
        beginNextShot()
    }

    func beginNextShot() {
        guard currentRound < totalRounds else {
            finishSession()
            return
        }
        phase = .shotActive
        ballProgress = 0
        shotTimer = 0
        reactedThisShot = false
        appliedDecoy = false
        decoyShift = 0
        ballNormalizedX = CGFloat(Double.random(in: 0.22...0.78))
    }

    func tick(delta: TimeInterval) {
        elapsed += delta
        guard phase == .shotActive else { return }
        shotTimer += delta
        let progress = CGFloat(shotTimer / shotDuration)
        if useDecoys, !appliedDecoy, progress >= 0.28 {
            appliedDecoy = true
            decoyShift = Bool.random() ? CGFloat(-0.12) : CGFloat(0.12)
        }
        ballProgress = min(1, progress)
        if !reactedThisShot, ballProgress >= 0.74 {
            misses += 1
            reactedThisShot = true
            completeShot()
        }
    }

    func handleGoalTap() {
        guard phase == .shotActive, !reactedThisShot else { return }
        if ballProgress >= 0.42, ballProgress <= 0.68 {
            saves += 1
            reactedThisShot = true
            completeShot()
        }
    }

    private func completeShot() {
        currentRound += 1
        let remainingShots = totalRounds - currentRound
        let savesStillPossible = saves + remainingShots
        if saves < savesNeeded, savesStillPossible < savesNeeded {
            phase = .lost
            return
        }
        if currentRound >= totalRounds {
            finishSession()
            return
        }
        phase = .betweenShots
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            guard let self else { return }
            if self.phase == .betweenShots {
                self.beginNextShot()
            }
        }
    }

    private func finishSession() {
        if saves >= savesNeeded {
            phase = .won
        } else {
            phase = .lost
        }
    }

    func ballPoint(in size: CGSize) -> CGPoint {
        let sway = decoyShift * (1 - abs(ballProgress - 0.5) * 1.4)
        let rawX = size.width * (ballNormalizedX + sway)
        let x = min(max(rawX, size.width * 0.08), size.width * 0.92)
        let y = size.height * 0.12 + size.height * 0.62 * ballProgress
        return CGPoint(x: x, y: y)
    }

    func makeOutcome(slot: ChallengeSlot) -> ActivityOutcome {
        let won = phase == .won
        let ratio = totalRounds > 0 ? Double(saves) / Double(totalRounds) * 100 : 0
        let stars = won ? starsForSaves(ratio) : 0
        return ActivityOutcome(
            slot: slot,
            starsEarned: stars,
            durationSeconds: elapsed,
            accuracyPercent: ratio,
            won: won
        )
    }

    private func starsForSaves(_ value: Double) -> Int {
        if value >= 88 { return 3 }
        if value >= 72 { return 2 }
        return 1
    }
}
