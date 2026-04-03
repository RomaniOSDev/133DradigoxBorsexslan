//
//  PrecisionPassViewModel.swift
//  133DradigoxBorsexslan
//

import Combine
import Foundation
import SwiftUI

final class PrecisionPassViewModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case aiming
        case flying
        case won
        case lost
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var targetsHit: Int = 0
    @Published private(set) var attempts: Int = 0
    @Published var aimVector: CGSize = .zero
    @Published private(set) var flightT: CGFloat = 0
    @Published private(set) var targetPhase: Double = 0

    let difficulty: Difficulty
    let requiredTargets: Int
    @Published private(set) var fieldSize: CGSize

    private var elapsed: TimeInterval = 0
    private var timeLimit: TimeInterval
    private var hitRegisteredForCurrentFlight = false

    init(difficulty: Difficulty, fieldSize: CGSize = CGSize(width: 320, height: 360)) {
        self.difficulty = difficulty
        self.fieldSize = fieldSize
        switch difficulty {
        case .easy:
            requiredTargets = 1
            timeLimit = 28
        case .normal:
            requiredTargets = 2
            timeLimit = 34
        case .hard:
            requiredTargets = 3
            timeLimit = 40
        }
    }

    func updateFieldSize(_ size: CGSize) {
        guard size.width > 1, size.height > 1 else { return }
        fieldSize = size
    }

    func startSession() {
        phase = .aiming
        targetsHit = 0
        attempts = 0
        elapsed = 0
        aimVector = .zero
        flightT = 0
        targetPhase = 0
        hitRegisteredForCurrentFlight = false
    }

    func tick(delta: TimeInterval) {
        guard phase == .aiming || phase == .flying else { return }
        elapsed += delta
        if phase == .aiming, elapsed > timeLimit {
            phase = .lost
            return
        }
        let speed: Double
        switch difficulty {
        case .easy: speed = 1.1
        case .normal: speed = 1.65
        case .hard: speed = 2.2
        }
        targetPhase += delta * speed
    }

    func beginFlight() {
        guard phase == .aiming else { return }
        let length = hypot(aimVector.width, aimVector.height)
        guard length > 24 else { return }
        phase = .flying
        flightT = 0
        attempts += 1
        hitRegisteredForCurrentFlight = false
    }

    func advanceFlight(delta: TimeInterval) {
        guard phase == .flying else { return }
        flightT += CGFloat(delta * 1.65)
        if flightT >= 1 {
            flightT = 1
            evaluateFlightEnd()
        }
    }

    private func evaluateFlightEnd() {
        if !hitRegisteredForCurrentFlight {
            phase = .lost
            return
        }
        if targetsHit >= requiredTargets {
            phase = .won
        } else {
            phase = .aiming
            aimVector = .zero
            flightT = 0
            hitRegisteredForCurrentFlight = false
        }
    }

    func registerHitIfNeeded(ballPoint: CGPoint, targetRect: CGRect) {
        guard phase == .flying, !hitRegisteredForCurrentFlight else { return }
        if targetRect.insetBy(dx: -6, dy: -6).contains(ballPoint) {
            hitRegisteredForCurrentFlight = true
            targetsHit += 1
        }
    }

    func ballPosition(start: CGPoint, drag: CGSize) -> CGPoint {
        let endX = start.x + drag.width * 1.35
        let endY = start.y + drag.height * 1.35
        let cx = (start.x + endX) / 2
        let cy = min(start.y, endY) - fieldSize.height * 0.18
        let t = flightT
        let ax = (1 - t) * (1 - t) * start.x + 2 * (1 - t) * t * cx + t * t * endX
        let ay = (1 - t) * (1 - t) * start.y + 2 * (1 - t) * t * cy + t * t * endY
        return CGPoint(x: ax, y: ay)
    }

    func currentTargetRect() -> CGRect {
        let baseY = fieldSize.height * 0.28
        let w: CGFloat
        let h: CGFloat
        switch difficulty {
        case .easy:
            w = fieldSize.width * 0.42
            h = 26
        case .normal:
            w = fieldSize.width * 0.34
            h = 22
        case .hard:
            w = fieldSize.width * 0.26
            h = 18
        }
        let span = fieldSize.width * 0.5 - w / 2
        let offset = sin(targetPhase) * Double(span)
        let x = fieldSize.width / 2 - w / 2 + CGFloat(offset)
        return CGRect(x: x, y: baseY, width: w, height: h)
    }

    func makeOutcome(slot: ChallengeSlot) -> ActivityOutcome {
        let won = phase == .won
        let acc: Double
        if attempts == 0 {
            acc = won ? 100 : 0
        } else {
            acc = won ? min(100, Double(targetsHit) / Double(attempts) * 100) : Double(targetsHit) / Double(max(attempts, 1)) * 80
        }
        let stars = won ? starsForAccuracy(acc) : 0
        return ActivityOutcome(
            slot: slot,
            starsEarned: stars,
            durationSeconds: elapsed,
            accuracyPercent: acc,
            won: won
        )
    }

    private func starsForAccuracy(_ value: Double) -> Int {
        if value >= 92 { return 3 }
        if value >= 78 { return 2 }
        return 1
    }
}
