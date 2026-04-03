//
//  VirtualMarathonViewModel.swift
//  133DradigoxBorsexslan
//

import Combine
import Foundation
import SwiftUI

final class VirtualMarathonViewModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case running
        case won
        case lost
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var stamina: Double = 100
    @Published private(set) var distanceProgress: Double = 0
    @Published private(set) var checkpointIndex: Int = 0
    @Published var paceSlider: Double = 0.55
    @Published private(set) var environmentHint: String = "Neutral track"

    let difficulty: Difficulty
    let totalCheckpoints: Int

    private var elapsed: TimeInterval = 0
    private var recoverCooldown: TimeInterval = 0
    private var environmentPhase: Int = 0
    private var environmentTimer: TimeInterval = 0

    init(difficulty: Difficulty) {
        self.difficulty = difficulty
        switch difficulty {
        case .easy:
            totalCheckpoints = 3
        case .normal:
            totalCheckpoints = 5
        case .hard:
            totalCheckpoints = 7
        }
    }

    func startRun() {
        phase = .running
        stamina = 100
        distanceProgress = 0
        checkpointIndex = 0
        elapsed = 0
        recoverCooldown = 0
        environmentPhase = 0
        environmentTimer = 0
        environmentHint = "Neutral track"
    }

    func recoverStamina() {
        guard phase == .running, recoverCooldown <= 0 else { return }
        stamina = min(100, stamina + 20)
        recoverCooldown = 3.6
    }

    func tick(delta: TimeInterval) {
        guard phase == .running else { return }
        elapsed += delta
        recoverCooldown = max(0, recoverCooldown - delta)
        environmentTimer += delta
        if environmentTimer >= 5 {
            environmentTimer = 0
            environmentPhase = (environmentPhase + 1) % 3
            switch environmentPhase {
            case 0:
                environmentHint = "Digital wind — pace costs more stamina"
            case 1:
                environmentHint = "Crowd lift — stride efficiency up"
            default:
                environmentHint = "Neutral track"
            }
        }

        let paceFactor = 0.45 + paceSlider * 0.55
        let windPenalty = environmentPhase == 0 ? 1.18 : environmentPhase == 1 ? 0.88 : 1.0
        let strideBoost = environmentPhase == 1 ? 1.1 : environmentPhase == 0 ? 0.9 : 1.0

        let baseDrain: Double
        switch difficulty {
        case .easy: baseDrain = 7.5
        case .normal: baseDrain = 10.5
        case .hard: baseDrain = 14
        }
        stamina -= baseDrain * paceFactor * windPenalty * delta
        if stamina <= 0 {
            stamina = 0
            phase = .lost
            return
        }

        let speed: Double
        switch difficulty {
        case .easy: speed = 0.11
        case .normal: speed = 0.095
        case .hard: speed = 0.082
        }
        distanceProgress += speed * paceFactor * strideBoost * delta
        distanceProgress = min(1, distanceProgress)

        while checkpointIndex < totalCheckpoints {
            let threshold = Double(checkpointIndex + 1) / Double(totalCheckpoints)
            if distanceProgress >= threshold {
                checkpointIndex += 1
                if checkpointIndex >= totalCheckpoints {
                    phase = .won
                    return
                }
            } else {
                break
            }
        }
    }

    func makeOutcome(slot: ChallengeSlot) -> ActivityOutcome {
        let won = phase == .won
        let stars = won ? starsForTime(elapsed) : 0
        return ActivityOutcome(
            slot: slot,
            starsEarned: stars,
            durationSeconds: elapsed,
            accuracyPercent: won ? min(100, stamina + 12) : 0,
            won: won
        )
    }

    private func starsForTime(_ t: TimeInterval) -> Int {
        let par: TimeInterval
        switch difficulty {
        case .easy: par = 58
        case .normal: par = 48
        case .hard: par = 40
        }
        if t <= par * 0.78 { return 3 }
        if t <= par * 1.12 { return 2 }
        return 1
    }
}
