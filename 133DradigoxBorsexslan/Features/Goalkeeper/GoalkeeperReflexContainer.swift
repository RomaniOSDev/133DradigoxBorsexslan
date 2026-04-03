//
//  GoalkeeperReflexContainer.swift
//  133DradigoxBorsexslan
//

import SwiftUI

struct GoalkeeperReflexContainer: View {
    @EnvironmentObject private var progress: GameProgressStore
    @StateObject private var model: GoalkeeperReflexViewModel
    @Binding var path: NavigationPath

    @State private var showResult = false
    @State private var pendingOutcome: ActivityOutcome?

    let difficulty: Difficulty

    init(difficulty: Difficulty, path: Binding<NavigationPath>) {
        self.difficulty = difficulty
        _path = path
        _model = StateObject(wrappedValue: GoalkeeperReflexViewModel(difficulty: difficulty))
    }

    var body: some View {
        ZStack {
            GoalkeeperReflexView(model: model) {
                guard !showResult else { return }
                let slot = ChallengeSlot(activity: .goalkeeperReflex, difficulty: difficulty)
                let outcome = model.makeOutcome(slot: slot)
                pendingOutcome = outcome
                if outcome.won {
                    progress.recordCompletion(outcome: outcome)
                }
                showResult = true
            }
            if showResult, let outcome = pendingOutcome {
                ActivityResultView(
                    outcome: outcome,
                    newAchievements: progress.newlyUnlockedAchievements(),
                    onNext: handleNext,
                    onRetry: handleRetry,
                    onBackToLevels: {
                        progress.acknowledgeNewAchievements()
                        path = NavigationPath()
                    },
                    hasNextLevel: progress.nextSlot(after: outcome.slot) != nil
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .id(difficulty)
        .navigationBarTitleDisplayMode(.inline)
        .animation(.spring(response: 0.45, dampingFraction: 0.86), value: showResult)
    }

    private func handleNext() {
        progress.acknowledgeNewAchievements()
        guard let current = pendingOutcome?.slot,
              let next = progress.nextSlot(after: current) else {
            path = NavigationPath()
            return
        }
        path = NavigationPath()
        switch next.activity {
        case .virtualMarathon:
            path.append(ChallengeRoute.marathon(next.difficulty))
        case .precisionPass:
            path.append(ChallengeRoute.precision(next.difficulty))
        case .goalkeeperReflex:
            path.append(ChallengeRoute.keeper(next.difficulty))
        }
    }

    private func handleRetry() {
        progress.acknowledgeNewAchievements()
        showResult = false
        pendingOutcome = nil
        model.startSession()
    }
}
