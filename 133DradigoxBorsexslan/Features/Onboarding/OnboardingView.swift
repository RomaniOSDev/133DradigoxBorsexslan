//
//  OnboardingView.swift
//  133DradigoxBorsexslan
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var progress: GameProgressStore
    @State private var page = 0

    var body: some View {
        ZStack {
            AppGradients.screenAmbient
                .ignoresSafeArea()
            AppGradients.screenLower
                .ignoresSafeArea()
            OnboardingBackdrop()
                .opacity(0.45)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            VStack(spacing: 0) {
                TabView(selection: $page) {
                    OnboardingPageOne(progress: $page)
                        .tag(0)
                    OnboardingPageTwo(progress: $page)
                        .tag(1)
                    OnboardingPageThree(onFinish: finish)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .tint(Color.appPrimary)
            }
        }
    }

    private func finish() {
        progress.completeOnboarding()
    }
}

// MARK: - Backdrop

private struct OnboardingBackdrop: View {
    var body: some View {
        Canvas { context, size in
            var arc1 = Path()
            arc1.move(to: CGPoint(x: -size.width * 0.05, y: size.height * 0.28))
            arc1.addQuadCurve(
                to: CGPoint(x: size.width * 1.05, y: size.height * 0.22),
                control: CGPoint(x: size.width * 0.5, y: size.height * 0.08)
            )
            context.stroke(arc1, with: .color(Color.appAccent.opacity(0.18)), lineWidth: 2.5)

            var arc2 = Path()
            arc2.move(to: CGPoint(x: size.width * 0.08, y: size.height * 0.72))
            arc2.addQuadCurve(
                to: CGPoint(x: size.width * 0.95, y: size.height * 0.68),
                control: CGPoint(x: size.width * 0.52, y: size.height * 0.55)
            )
            context.stroke(arc2, with: .color(Color.appPrimary.opacity(0.12)), lineWidth: 3)

            let orb = Path(ellipseIn: CGRect(x: size.width * 0.75, y: size.height * 0.12, width: size.width * 0.35, height: size.width * 0.35))
            context.fill(orb, with: .color(Color.appAccent.opacity(0.06)))
            let orb2 = Path(ellipseIn: CGRect(x: -size.width * 0.08, y: size.height * 0.45, width: size.width * 0.4, height: size.width * 0.4))
            context.fill(orb2, with: .color(Color.appPrimary.opacity(0.05)))
        }
    }
}

// MARK: - Shared layout

private struct OnboardingPageChrome<Graphic: View>: View {
    let step: Int
    let totalSteps: Int
    let title: String
    let subtitle: String
    @ViewBuilder var graphic: () -> Graphic
    let buttonTitle: String
    let buttonAction: () -> Void

    @State private var headerVisible = false
    @State private var panelVisible = false

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            let graphicH = min(240, max(120, h * 0.26))
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 10)
                    stepBadge
                        .opacity(headerVisible ? 1 : 0)
                        .offset(y: headerVisible ? 0 : 8)
                    VStack(spacing: 16) {
                        Text(title)
                            .font(.title2.weight(.bold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.appPrimary, Color.appAccent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color.appPrimary.opacity(0.12), radius: 6, y: 3)
                        Text(subtitle)
                            .font(.body)
                            .foregroundStyle(Color.appTextSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 18)
                    .frame(maxWidth: .infinity)
                    .appElevatedCard(cornerRadius: 20)
                    .padding(.horizontal, 16)
                    .opacity(headerVisible ? 1 : 0)
                    .offset(y: headerVisible ? 0 : 12)
                    Spacer(minLength: 10)
                    graphic()
                        .frame(maxWidth: .infinity)
                        .frame(height: graphicH)
                        .padding(16)
                        .appPlayfieldShell(cornerRadius: 22)
                        .padding(.horizontal, 16)
                        .opacity(panelVisible ? 1 : 0)
                        .scaleEffect(panelVisible ? 1 : 0.96)
                    Spacer(minLength: 10)
                    PrimaryButton(title: buttonTitle, action: buttonAction)
                        .padding(.horizontal, 16)
                        .opacity(panelVisible ? 1 : 0)
                        .offset(y: panelVisible ? 0 : 10)
                    Spacer(minLength: 12)
                }
                .frame(minHeight: h)
                .frame(maxWidth: geo.size.width)
            }
            .frame(width: geo.size.width, height: h)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                headerVisible = true
            }
            withAnimation(.spring(response: 0.58, dampingFraction: 0.84).delay(0.08)) {
                panelVisible = true
            }
        }
    }

    private var stepBadge: some View {
        Text("Step \(step) of \(totalSteps)")
            .font(.caption.weight(.bold))
            .foregroundStyle(Color.appAccent)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(AppGradients.cardFace)
                    .shadow(color: Color.appPrimary.opacity(0.1), radius: 8, x: 0, y: 4)
            }
            .overlay(
                Capsule()
                    .strokeBorder(AppGradients.cardRim, lineWidth: 1)
            )
            .padding(.bottom, 6)
    }
}

private struct OnboardingPageOne: View {
    @Binding var progress: Int
    @State private var drawProgress: CGFloat = 0

    var body: some View {
        OnboardingPageChrome(
            step: 1,
            totalSteps: 3,
            title: "Train with purpose",
            subtitle: "Interactive drills sharpen endurance, accuracy, and reflexes.",
            graphic: {
                TrackShape(progress: drawProgress)
                    .stroke(
                        LinearGradient(
                            colors: [Color.appAccent, Color.appPrimary.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round)
                    )
                    .shadow(color: Color.appAccent.opacity(0.45), radius: 10, y: 4)
                    .padding(.horizontal, 28)
            },
            buttonTitle: "Continue"
        ) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                progress = 1
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                drawProgress = 1
            }
        }
    }
}

private struct TrackShape: Shape {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        p.move(to: CGPoint(x: 0, y: h * 0.55))
        p.addQuadCurve(
            to: CGPoint(x: w, y: h * 0.45),
            control: CGPoint(x: w * 0.5, y: h * 0.1)
        )
        return p.trimmedPath(from: 0, to: progress)
    }
}

private struct OnboardingPageTwo: View {
    @Binding var progress: Int
    @State private var ringScale: CGFloat = 0.72

    var body: some View {
        OnboardingPageChrome(
            step: 2,
            totalSteps: 3,
            title: "Aim with precision",
            subtitle: "Drag, release, and thread moving targets with smooth arcs.",
            graphic: {
                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.appAccent.opacity(0.5 - Double(i) * 0.1),
                                        Color.appPrimary.opacity(0.35 - Double(i) * 0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 4
                            )
                            .frame(width: 80 + CGFloat(i) * 38, height: 80 + CGFloat(i) * 38)
                            .scaleEffect(ringScale)
                            .shadow(color: Color.appAccent.opacity(0.15 - Double(i) * 0.03), radius: 8, y: 3)
                    }
                    Circle()
                        .fill(AppGradients.primaryCTA)
                        .frame(width: 22, height: 22)
                        .shadow(color: Color.appPrimary.opacity(0.4), radius: 8, y: 3)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.appTextPrimary.opacity(0.25), lineWidth: 1)
                        )
                }
                .onAppear {
                    withAnimation(.spring(response: 0.55, dampingFraction: 0.55).repeatForever(autoreverses: true)) {
                        ringScale = 1.06
                    }
                }
            },
            buttonTitle: "Next"
        ) {
            withAnimation(.easeInOut(duration: 0.35)) {
                progress = 2
            }
        }
    }
}

private struct OnboardingPageThree: View {
    let onFinish: () -> Void
    @State private var gloveLift: CGFloat = 0

    var body: some View {
        OnboardingPageChrome(
            step: 3,
            totalSteps: 3,
            title: "React like a keeper",
            subtitle: "Tap the goal zone to block shots as pace and angles ramp up.",
            graphic: {
                GoalIllustration(lift: gloveLift)
                    .padding(.horizontal, 20)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                            gloveLift = 1
                        }
                    }
            },
            buttonTitle: "Get Started",
            buttonAction: onFinish
        )
    }
}

private struct GoalIllustration: View {
    var lift: CGFloat

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack(alignment: .bottom) {
                Path { p in
                    p.move(to: CGPoint(x: w * 0.1, y: h))
                    p.addLine(to: CGPoint(x: w * 0.1, y: h * 0.35))
                    p.addQuadCurve(to: CGPoint(x: w * 0.9, y: h * 0.35), control: CGPoint(x: w * 0.5, y: h * 0.12))
                    p.addLine(to: CGPoint(x: w * 0.9, y: h))
                }
                .stroke(
                    LinearGradient(
                        colors: [Color.appPrimary, Color.appAccent.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 5
                )
                .shadow(color: Color.appPrimary.opacity(0.2), radius: 6, y: 2)
                Circle()
                    .fill(AppGradients.progressFill)
                    .frame(width: 24, height: 24)
                    .shadow(color: Color.appAccent.opacity(0.5), radius: 8, y: 3)
                    .offset(x: w * 0.15, y: -h * 0.45 + lift * -18)
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimary.opacity(0.45), Color.appAccent.opacity(0.28)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: w * 0.72, height: h * 0.22)
                    .shadow(color: Color.appPrimary.opacity(0.15), radius: 6, y: 2)
                    .offset(y: -h * 0.11 + lift * -10)
            }
        }
    }
}
