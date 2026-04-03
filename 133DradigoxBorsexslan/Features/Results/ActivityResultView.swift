//
//  ActivityResultView.swift
//  133DradigoxBorsexslan
//

import SwiftUI

struct ActivityResultView: View {
    let outcome: ActivityOutcome
    let newAchievements: [Achievement]
    let onNext: () -> Void
    let onRetry: () -> Void
    let onBackToLevels: () -> Void
    let hasNextLevel: Bool

    @State private var visibleStars = 0
    @State private var showBanner = false

    var body: some View {
        ZStack {
            AppGradients.overlayScrim
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    if showBanner, let first = newAchievements.first {
                        AchievementBanner(title: "New milestone", subtitle: first.title)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    Text(outcome.won ? "Great effort" : "Keep pushing")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.appPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.top, showBanner ? 8 : 28)
                    HStack(spacing: 18) {
                        ForEach(0..<3, id: \.self) { index in
                            ResultStarView(filled: index < min(visibleStars, outcome.starsEarned))
                        }
                    }
                    .padding(.vertical, 8)
                    VStack(spacing: 12) {
                        statRow(label: "Time", value: formatTime(outcome.durationSeconds))
                        statRow(label: "Accuracy", value: outcome.won ? String(format: "%.0f%%", outcome.accuracyPercent) : "—")
                        statRow(label: "Stars earned", value: "\(outcome.starsEarned)")
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .appElevatedCard(cornerRadius: 16)
                    HStack(spacing: 12) {
                        if hasNextLevel && outcome.won {
                            PrimaryButton(title: "Next Level") {
                                onNext()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        SecondaryButton(title: "Retry") {
                            onRetry()
                        }
                        .frame(maxWidth: .infinity)
                        SecondaryButton(title: "Back to Levels") {
                            onBackToLevels()
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            animateStars()
            if !newAchievements.isEmpty {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.82).delay(0.05)) {
                    showBanner = true
                }
            }
        }
    }

    private func animateStars() {
        visibleStars = 0
        let count = outcome.starsEarned
        guard count > 0 else { return }
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.55)) {
                    visibleStars = i + 1
                }
            }
        }
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 8)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private func formatTime(_ t: TimeInterval) -> String {
        String(format: "%.1fs", t)
    }
}

private struct ResultStarView: View {
    let filled: Bool

    var body: some View {
        Group {
            if filled {
                StarShape()
                    .fill(AppGradients.progressFill)
            } else {
                StarShape()
                    .fill(Color.appTextSecondary.opacity(0.25))
            }
        }
        .frame(width: 46, height: 46)
        .shadow(color: filled ? Color.appAccent.opacity(0.75) : .clear, radius: 14, y: 2)
        .shadow(color: filled ? Color.appPrimary.opacity(0.35) : .clear, radius: 8, y: 0)
        .frame(width: 56, height: 56)
    }
}

private struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        var p = Path()
        let points = 5
        for i in 0..<(points * 2) {
            let angle = CGFloat(i) * .pi / CGFloat(points) - .pi / 2
            let radius = i.isMultiple(of: 2) ? r : r * 0.45
            let pt = CGPoint(x: c.x + cos(angle) * radius, y: c.y + sin(angle) * radius)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }
}

private struct AchievementBanner: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(subtitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppGradients.primaryCTA)
                .shadow(color: Color.appPrimary.opacity(0.45), radius: 16, x: 0, y: 8)
                .shadow(color: Color.appAccent.opacity(0.25), radius: 6, y: 3)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.appTextPrimary.opacity(0.22), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
}
