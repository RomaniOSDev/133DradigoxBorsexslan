//
//  VirtualMarathonView.swift
//  133DradigoxBorsexslan
//

import Combine
import SwiftUI

struct VirtualMarathonView: View {
    @ObservedObject var model: VirtualMarathonViewModel
    let onFinished: () -> Void

    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                progressSection
                runnerSection
                controls
                if model.phase == .idle {
                    PrimaryButton(title: "Start Run") {
                        model.startRun()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .appScreenBackground()
        .onReceive(timer) { _ in
            if model.phase == .running {
                model.tick(delta: 1.0 / 60.0)
            }
        }
        .onChange(of: model.phase) { newPhase in
            if newPhase == .won || newPhase == .lost {
                onFinished()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Virtual Marathon")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(model.environmentHint)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppGradients.progressTrack)
                    Capsule()
                        .fill(AppGradients.progressFill)
                        .frame(width: max(8, geo.size.width * model.distanceProgress))
                }
            }
            .frame(height: 14)
            .shadow(color: Color.appAccent.opacity(0.18), radius: 4, y: 2)
            HStack {
                Text("Distance")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("\(model.checkpointIndex)/\(model.totalCheckpoints) checkpoints")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(14)
        .appElevatedCard(cornerRadius: 14)
    }

    private var runnerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Stamina")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                Spacer()
                Text("\(Int(model.stamina))%")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(Color.appAccent)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(AppGradients.progressTrack)
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(AppGradients.progressFill)
                        .frame(width: max(10, geo.size.width * (model.stamina / 100)))
                }
            }
            .frame(height: 16)
            .shadow(color: Color.appPrimary.opacity(0.12), radius: 4, y: 2)
            RunnerFigure(isRunning: model.phase == .running)
                .frame(height: 120)
        }
        .padding(14)
        .appElevatedCard(cornerRadius: 14)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pace")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
            Slider(value: $model.paceSlider, in: 0.25...1)
                .tint(Color.appAccent)
                .disabled(model.phase != .running)
            HStack(spacing: 12) {
                Button(action: { model.recoverStamina() }) {
                    Text("Recover")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background {
                            Group {
                                if model.phase == .running {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(AppGradients.primaryCTA)
                                        .shadow(color: Color.appPrimary.opacity(0.3), radius: 8, y: 4)
                                } else {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.appPrimary.opacity(0.35))
                                }
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.appTextPrimary.opacity(0.15), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .disabled(model.phase != .running)
            }
        }
        .padding(14)
        .appElevatedCard(cornerRadius: 14)
    }
}

private struct RunnerFigure: View {
    let isRunning: Bool

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !isRunning)) { timeline in
            Canvas { context, size in
                var leg = Path()
                leg.move(to: CGPoint(x: size.width * 0.42, y: size.height * 0.62))
                leg.addLine(to: CGPoint(x: size.width * 0.48, y: size.height * 0.92))
                context.stroke(leg, with: .color(Color.appPrimary), lineWidth: 5)
                var leg2 = Path()
                leg2.move(to: CGPoint(x: size.width * 0.58, y: size.height * 0.62))
                leg2.addLine(to: CGPoint(x: size.width * 0.52, y: size.height * 0.92))
                context.stroke(leg2, with: .color(Color.appPrimary), lineWidth: 5)
                var torso = Path()
                torso.move(to: CGPoint(x: size.width * 0.5, y: size.height * 0.3))
                torso.addLine(to: CGPoint(x: size.width * 0.5, y: size.height * 0.62))
                context.stroke(torso, with: .color(Color.appAccent), lineWidth: 6)
                let head = CGRect(x: size.width * 0.43, y: size.height * 0.12, width: size.width * 0.14, height: size.height * 0.18)
                context.fill(Path(ellipseIn: head), with: .color(Color.appPrimary.opacity(0.85)))
            }
            .offset(y: verticalBounce(at: timeline.date))
        }
    }

    private func verticalBounce(at date: Date) -> CGFloat {
        guard isRunning else { return 0 }
        return CGFloat(sin(date.timeIntervalSinceReferenceDate * 12) * 6)
    }
}
