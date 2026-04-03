//
//  GoalkeeperReflexView.swift
//  133DradigoxBorsexslan
//

import Combine
import SwiftUI

struct GoalkeeperReflexView: View {
    @ObservedObject var model: GoalkeeperReflexViewModel
    let onFinished: () -> Void

    private let tick = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text("Goalkeeper Reflex")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.appPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 16)
                GeometryReader { geo in
                    let size = geo.size
                    ZStack {
                        GoalOutline(size: size)
                        if model.phase == .shotActive || model.phase == .betweenShots {
                            Circle()
                                .fill(AppGradients.progressFill)
                                .frame(width: 22, height: 22)
                                .shadow(color: Color.appAccent.opacity(0.5), radius: 8, y: 3)
                                .position(model.ballPoint(in: size))
                            ShotTrail(from: CGPoint(x: size.width * 0.5, y: size.height * 0.08), to: model.ballPoint(in: size))
                        }
                    }
                    .appPlayfieldShell(cornerRadius: 18)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        model.handleGoalTap()
                    }
                }
                .frame(height: 360)
                .padding(.horizontal, 16)
                statusRow
                if model.phase == .idle {
                    PrimaryButton(title: "Start Session") {
                        model.startSession()
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 16)
        }
        .appScreenBackground()
        .onReceive(tick) { _ in
            model.tick(delta: 1.0 / 60.0)
        }
        .onChange(of: model.phase) { newPhase in
            if newPhase == .won || newPhase == .lost {
                onFinished()
            }
        }
    }

    private var statusRow: some View {
        HStack {
            Text("Saves \(model.saves)/\(model.savesNeeded)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
            Text("Round \(min(model.currentRound + 1, model.totalRounds))/\(model.totalRounds)")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 16)
    }
}

private struct GoalOutline: View {
    let size: CGSize

    var body: some View {
        Path { p in
            let w = size.width
            let h = size.height
            p.move(to: CGPoint(x: w * 0.12, y: h * 0.9))
            p.addLine(to: CGPoint(x: w * 0.12, y: h * 0.28))
            p.addQuadCurve(to: CGPoint(x: w * 0.88, y: h * 0.28), control: CGPoint(x: w * 0.5, y: h * 0.08))
            p.addLine(to: CGPoint(x: w * 0.88, y: h * 0.9))
        }
        .stroke(
            LinearGradient(
                colors: [Color.appPrimary, Color.appAccent.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: 4
        )
        .shadow(color: Color.appPrimary.opacity(0.2), radius: 4, y: 2)
    }
}

private struct ShotTrail: View {
    let from: CGPoint
    let to: CGPoint

    var body: some View {
        Path { p in
            p.move(to: from)
            p.addQuadCurve(to: to, control: CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2 - 40))
        }
        .stroke(Color.appAccent.opacity(0.35), style: StrokeStyle(lineWidth: 3, dash: [6, 6]))
    }
}
