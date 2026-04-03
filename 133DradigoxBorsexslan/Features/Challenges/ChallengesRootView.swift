//
//  ChallengesRootView.swift
//  133DradigoxBorsexslan
//

import SwiftUI

enum ChallengeRoute: Hashable {
    case marathon(Difficulty)
    case precision(Difficulty)
    case keeper(Difficulty)
}

struct ChallengesRootView: View {
    @EnvironmentObject private var progress: GameProgressStore
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ChallengesHubView(path: $path)
                .navigationDestination(for: ChallengeRoute.self) { route in
                    switch route {
                    case .marathon(let d):
                        VirtualMarathonContainer(difficulty: d, path: $path)
                    case .precision(let d):
                        PrecisionPassContainer(difficulty: d, path: $path)
                    case .keeper(let d):
                        GoalkeeperReflexContainer(difficulty: d, path: $path)
                    }
                }
        }
    }
}

struct ChallengesHubView: View {
    @EnvironmentObject private var progress: GameProgressStore
    @Binding var path: NavigationPath
    @State private var difficulty: Difficulty = .easy

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Pick a difficulty")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.appPrimary)
                    .padding(.horizontal, 16)
                Picker("Difficulty", selection: $difficulty) {
                    ForEach(Difficulty.allCases, id: \.self) { d in
                        Text(d.displayTitle).tag(d)
                    }
                }
                .pickerStyle(.segmented)
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppGradients.cardFace)
                        .shadow(color: Color.appPrimary.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AppGradients.cardRim, lineWidth: 1)
                )
                .padding(.horizontal, 16)
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(ActivityKind.allCases, id: \.self) { activity in
                        let slot = ChallengeSlot(activity: activity, difficulty: difficulty)
                        ChallengeTile(slot: slot) {
                            pushActivity(activity)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
        .appScreenBackground()
        .navigationTitle("Challenges")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func pushActivity(_ activity: ActivityKind) {
        switch activity {
        case .virtualMarathon:
            path.append(ChallengeRoute.marathon(difficulty))
        case .precisionPass:
            path.append(ChallengeRoute.precision(difficulty))
        case .goalkeeperReflex:
            path.append(ChallengeRoute.keeper(difficulty))
        }
    }
}

private struct ChallengeTile: View {
    @EnvironmentObject private var progress: GameProgressStore
    let slot: ChallengeSlot
    let onTap: () -> Void

    private var unlocked: Bool {
        progress.isUnlocked(slot)
    }

    private var starCount: Int {
        progress.stars(for: slot)
    }

    var body: some View {
        Button(action: {
            if unlocked { onTap() }
        }) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppGradients.playfieldPanel)
                        .shadow(color: Color.appPrimary.opacity(0.08), radius: 6, y: 3)
                    ActivityGlyph(kind: slot.activity)
                        .opacity(unlocked ? 1 : 0.35)
                    if !unlocked {
                        LockGlyph()
                            .stroke(Color.appTextSecondary, lineWidth: 3)
                            .frame(width: 28, height: 28)
                    }
                }
                .frame(height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AppGradients.cardRim, lineWidth: 1)
                )
                Text(slot.activity.shortLabel)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(i < starCount ? Color.appAccent : Color.appTextSecondary.opacity(0.25))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .appElevatedCard(cornerRadius: 16)
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
    }
}
