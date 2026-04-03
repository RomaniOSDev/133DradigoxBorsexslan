//
//  PrecisionPassView.swift
//  133DradigoxBorsexslan
//

import Combine
import SwiftUI

struct PrecisionPassView: View {
    @ObservedObject var model: PrecisionPassViewModel
    let onFinished: () -> Void

    @State private var fieldSize: CGSize = .zero
    @State private var ballStart: CGPoint = .zero

    private let tick = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text("Precision Pass")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.appPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 16)
                GeometryReader { geo in
                    let size = geo.size
                    let start = CGPoint(x: size.width / 2, y: size.height * 0.82)
                    ZStack {
                        TargetPath(rect: model.currentTargetRect())
                        Circle()
                            .fill(AppGradients.primaryCTA)
                            .frame(width: 22, height: 22)
                            .shadow(color: Color.appPrimary.opacity(0.35), radius: 5, y: 2)
                            .position(start)
                        if model.phase == .flying || model.phase == .aiming {
                            let origin = ballStart == .zero ? start : ballStart
                            let ballPos = model.ballPosition(start: origin, drag: model.aimVector)
                            if model.phase == .flying {
                                Circle()
                                    .fill(AppGradients.progressFill)
                                    .frame(width: 20, height: 20)
                                    .shadow(color: Color.appAccent.opacity(0.45), radius: 6, y: 2)
                                    .position(ballPos)
                            }
                        }
                        Path { p in
                            p.move(to: start)
                            p.addLine(to: CGPoint(x: start.x + model.aimVector.width, y: start.y + model.aimVector.height))
                        }
                        .stroke(Color.appPrimary.opacity(model.phase == .aiming ? 0.45 : 0), lineWidth: 3)
                    }
                    .appPlayfieldShell(cornerRadius: 18)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard model.phase == .aiming else { return }
                                model.aimVector = CGSize(
                                    width: value.translation.width,
                                    height: value.translation.height
                                )
                            }
                            .onEnded { _ in
                                guard model.phase == .aiming else { return }
                                ballStart = start
                                model.beginFlight()
                            }
                    )
                    .onAppear {
                        fieldSize = size
                        ballStart = start
                        model.updateFieldSize(size)
                    }
                    .onChange(of: geo.size) { newSize in
                        fieldSize = newSize
                        model.updateFieldSize(newSize)
                    }
                }
                .frame(height: 360)
                .padding(.horizontal, 16)
                statusRow
                if model.phase == .idle {
                    PrimaryButton(title: "Start Drill") {
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
            if model.phase == .flying {
                model.advanceFlight(delta: 1.0 / 60.0)
                let start = CGPoint(x: fieldSize.width / 2, y: fieldSize.height * 0.82)
                let origin = ballStart == .zero ? start : ballStart
                let ball = model.ballPosition(start: origin, drag: model.aimVector)
                model.registerHitIfNeeded(ballPoint: ball, targetRect: model.currentTargetRect())
            }
        }
        .onChange(of: model.phase) { newPhase in
            if newPhase == .aiming {
                ballStart = .zero
            }
            if newPhase == .won || newPhase == .lost {
                onFinished()
            }
        }
    }

    private var statusRow: some View {
        HStack {
            Text("Targets \(model.targetsHit)/\(model.requiredTargets)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
            Text(model.phase == .aiming ? "Drag and release" : model.phase == .flying ? "In flight" : "")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 16)
    }
}

private struct TargetPath: View {
    let rect: CGRect

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color.appAccent.opacity(0.18), Color.appPrimary.opacity(0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(AppGradients.progressFill, lineWidth: 3)
            )
            .shadow(color: Color.appAccent.opacity(0.25), radius: 6, y: 2)
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
    }
}
