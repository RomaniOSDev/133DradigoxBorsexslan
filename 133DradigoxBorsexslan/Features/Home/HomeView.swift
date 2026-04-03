//
//  HomeView.swift
//  133DradigoxBorsexslan
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progress: GameProgressStore
    @EnvironmentObject private var tabRouter: TabRouter

    @State private var headerAppeared = false
    @State private var cardsAppeared = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                        .opacity(headerAppeared ? 1 : 0)
                        .offset(y: headerAppeared ? 0 : 12)
                    VStack(alignment: .leading, spacing: 20) {
                        heroStatsCard
                        nextUpCard
                        journeyCard
                        activitiesSection
                        achievementsSection
                    }
                    .padding(.top, 20)
                    .opacity(cardsAppeared ? 1 : 0)
                    .offset(y: cardsAppeared ? 0 : 16)
                }
                .padding(.bottom, 28)
            }
            .background {
                ZStack {
                    AppGradients.screenAmbient
                    AppGradients.screenLower
                    HomeFieldBackdrop()
                        .opacity(0.32)
                }
                .ignoresSafeArea()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                headerAppeared = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.08)) {
                cardsAppeared = true
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greetingLine)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appAccent)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("Training hub")
                .font(.title.weight(.bold))
                .foregroundStyle(Color.appPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(subtitleLine)
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    private var greetingLine: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Welcome back"
        }
    }

    private var subtitleLine: String {
        if progress.totalActivitiesPlayed == 0 {
            return "Start a challenge to build your stats and unlock stars."
        }
        if completionRatio >= 1 {
            return "You cleared every slot. Polish your stars or replay on harder settings."
        }
        return "Track stars, sessions, and your path through every difficulty."
    }

    // MARK: - Hero stats

    private var heroStatsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total stars")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("\(progress.totalStarsCollected())")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text("of \(maxStarCapacity)")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer(minLength: 12)
                ZStack {
                    Circle()
                        .stroke(AppGradients.progressTrack, lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: completionRatio)
                        .stroke(AppGradients.progressFill, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 88, height: 88)
                .shadow(color: Color.appAccent.opacity(0.25), radius: 8, y: 4)
            }
            HStack(spacing: 10) {
                HomeMetricChip(
                    title: "Sessions",
                    value: "\(progress.totalActivitiesPlayed)",
                    accent: Color.appPrimary
                )
                HomeMetricChip(
                    title: "Time",
                    value: formatDurationShort(progress.totalPlaySeconds),
                    accent: Color.appAccent
                )
                HomeMetricChip(
                    title: "Slots done",
                    value: "\(clearedSlotsCount)/\(GameProgressStore.challengeOrder.count)",
                    accent: Color.appPrimary
                )
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedCard(cornerRadius: 20)
        .padding(.horizontal, 16)
    }

    private var maxStarCapacity: Int {
        GameProgressStore.challengeOrder.count * 3
    }

    private var completionRatio: Double {
        let total = GameProgressStore.challengeOrder.count
        guard total > 0 else { return 0 }
        let sum = GameProgressStore.challengeOrder.reduce(0) { $0 + progress.stars(for: $1) }
        return Double(sum) / Double(total * 3)
    }

    private var clearedSlotsCount: Int {
        GameProgressStore.challengeOrder.filter { progress.stars(for: $0) > 0 }.count
    }

    // MARK: - Next up

    private var nextUpCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Next up")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.appPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appAccent)
            }
            if let slot = nextFocusSlot {
                Text("\(slot.activity.displayTitle) · \(slot.difficulty.displayTitle)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appAccent)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                Text(nextSlotDetail(slot))
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                PrimaryButton(title: "Open Challenges") {
                    tabRouter.openChallenges()
                }
            } else {
                Text("Every challenge cleared with top marks.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                PrimaryButton(title: "Replay Challenges") {
                    tabRouter.openChallenges()
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedCard(cornerRadius: 18)
        .padding(.horizontal, 16)
    }

    private var nextFocusSlot: ChallengeSlot? {
        GameProgressStore.challengeOrder.first { slot in
            progress.isUnlocked(slot) && progress.stars(for: slot) < 3
        }
    }

    private func nextSlotDetail(_ slot: ChallengeSlot) -> String {
        let s = progress.stars(for: slot)
        if s == 0 {
            return "Not completed yet — jump in and earn your first stars."
        }
        return "Current best: \(s) stars. Push for a perfect three."
    }

    // MARK: - Journey

    private var journeyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Challenge journey")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("Share of total stars across all activities and difficulties.")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppGradients.progressTrack)
                    Capsule()
                        .fill(AppGradients.progressFill)
                        .frame(width: max(12, geo.size.width * completionRatio))
                }
            }
            .frame(height: 12)
            .shadow(color: Color.appAccent.opacity(0.2), radius: 4, y: 2)
            HStack {
                Text("\(Int((completionRatio * 100).rounded()))% complete")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appAccent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Button(action: { tabRouter.openLeaderboard() }) {
                    Text("Records")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 14)
                        .frame(minHeight: 44)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(AppGradients.cardFace)
                                .shadow(color: Color.appPrimary.opacity(0.1), radius: 6, y: 3)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(AppGradients.cardRim, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedCard(cornerRadius: 18)
        .padding(.horizontal, 16)
    }

    // MARK: - Activities

    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Activities")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.appPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Button(action: { tabRouter.openChallenges() }) {
                    Text("Browse")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appAccent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(minHeight: 44)
                        .padding(.horizontal, 8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            VStack(spacing: 12) {
                ForEach(ActivityKind.allCases, id: \.self) { activity in
                    HomeActivityCard(activity: activity)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Achievements

    private var achievementsSection: some View {
        let list = progress.unlockedAchievementDefinitions()
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Milestones")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.appPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Button(action: { tabRouter.openProfile() }) {
                    Text("Profile")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appAccent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(minHeight: 44)
                        .padding(.horizontal, 8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            if list.isEmpty {
                Text("Complete challenges to unlock milestones. They also appear on your profile.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appElevatedCard(cornerRadius: 16)
                    .padding(.horizontal, 16)
            } else {
                VStack(spacing: 10) {
                    ForEach(list.prefix(3)) { item in
                        HStack(alignment: .top, spacing: 12) {
                            MilestoneSeal()
                                .frame(width: 40, height: 40)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                Text(item.detail)
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.7)
                            }
                            Spacer(minLength: 4)
                        }
                        .padding(14)
                        .appElevatedCard(cornerRadius: 14)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func formatDurationShort(_ t: TimeInterval) -> String {
        guard t >= 60 else { return String(format: "%ds", Int(t)) }
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Subviews

private struct HomeMetricChip: View {
    let title: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppGradients.cardFace)
                .shadow(color: Color.appPrimary.opacity(0.09), radius: 8, x: 0, y: 4)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [accent.opacity(0.35), Color.appPrimary.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

private struct HomeActivityCard: View {
    @EnvironmentObject private var progress: GameProgressStore
    let activity: ActivityKind

    private var slots: [ChallengeSlot] {
        GameProgressStore.challengeOrder.filter { $0.activity == activity }
    }

    private var totalStars: Int {
        slots.reduce(0) { $0 + progress.stars(for: $1) }
    }

    private var segmentFill: Double {
        Double(totalStars) / 9.0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appPrimary.opacity(0.18),
                                    Color.appAccent.opacity(0.14)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.appPrimary.opacity(0.12), radius: 6, y: 3)
                    ActivityGlyph(kind: activity)
                }
                .frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.displayTitle)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("\(totalStars) stars · Easy / Normal / Hard")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                }
                Spacer(minLength: 8)
                StarCluster(count: totalStars, maxCount: 9)
            }
            HStack(spacing: 6) {
                ForEach(Difficulty.allCases, id: \.self) { diff in
                    DifficultyStarsRow(
                        title: diff.displayTitle,
                        stars: progress.stars(for: ChallengeSlot(activity: activity, difficulty: diff))
                    )
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(AppGradients.progressTrack)
                    Capsule()
                        .fill(AppGradients.progressFill)
                        .frame(width: max(8, geo.size.width * segmentFill))
                }
            }
            .frame(height: 6)
            .shadow(color: Color.appAccent.opacity(0.15), radius: 3, y: 1)
        }
        .padding(14)
        .appElevatedCard(cornerRadius: 16)
    }
}

private struct DifficultyStarsRow: View {
    let title: String
    let stars: Int

    var body: some View {
        VStack(spacing: 4) {
            Text(title.prefix(1))
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(i < stars ? Color.appAccent : Color.appTextSecondary.opacity(0.2))
                        .frame(width: 6, height: 6)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct StarCluster: View {
    let count: Int
    let maxCount: Int

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<min(count, 5), id: \.self) { _ in
                SmallStarShape()
                    .fill(Color.appAccent)
                    .frame(width: 11, height: 11)
            }
            if count > 5 {
                Text("+\(count - 5)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color.appPrimary)
                    .lineLimit(1)
            } else if count == 0 {
                Text("—")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .accessibilityLabel("\(count) of \(maxCount) stars")
    }
}

private struct SmallStarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        var p = Path()
        let points = 5
        for i in 0..<(points * 2) {
            let angle = CGFloat(i) * .pi / CGFloat(points) - .pi / 2
            let radius = i.isMultiple(of: 2) ? r : r * 0.42
            let pt = CGPoint(x: c.x + cos(angle) * radius, y: c.y + sin(angle) * radius)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }
}

private struct MilestoneSeal: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.appPrimary.opacity(0.12))
            Path { p in
                let w: CGFloat = 40
                p.move(to: CGPoint(x: w * 0.5, y: w * 0.22))
                p.addLine(to: CGPoint(x: w * 0.72, y: w * 0.38))
                p.addLine(to: CGPoint(x: w * 0.64, y: w * 0.65))
                p.addLine(to: CGPoint(x: w * 0.36, y: w * 0.65))
                p.addLine(to: CGPoint(x: w * 0.28, y: w * 0.38))
                p.closeSubpath()
            }
            .fill(Color.appAccent.opacity(0.35))
            .frame(width: 40, height: 40)
            SmallStarShape()
                .fill(Color.appPrimary)
                .frame(width: 14, height: 14)
        }
    }
}

private struct HomeFieldBackdrop: View {
    var body: some View {
        Canvas { context, size in
            var band = Path()
            band.move(to: CGPoint(x: 0, y: size.height * 0.42))
            band.addQuadCurve(
                to: CGPoint(x: size.width, y: size.height * 0.38),
                control: CGPoint(x: size.width * 0.5, y: size.height * 0.22)
            )
            context.stroke(band, with: .color(Color.appAccent.opacity(0.2)), lineWidth: 2)
            var band2 = Path()
            band2.move(to: CGPoint(x: 0, y: size.height * 0.52))
            band2.addQuadCurve(
                to: CGPoint(x: size.width, y: size.height * 0.48),
                control: CGPoint(x: size.width * 0.5, y: size.height * 0.34)
            )
            context.stroke(band2, with: .color(Color.appPrimary.opacity(0.12)), lineWidth: 3)
        }
        .allowsHitTesting(false)
    }
}

struct ActivityGlyph: View {
    let kind: ActivityKind

    var body: some View {
        Group {
            switch kind {
            case .virtualMarathon:
                Path { p in
                    p.addEllipse(in: CGRect(x: 8, y: 14, width: 28, height: 16))
                }
                .fill(Color.appPrimary)
            case .precisionPass:
                Circle()
                    .fill(Color.appAccent)
                    .frame(width: 18, height: 18)
            case .goalkeeperReflex:
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(Color.appPrimary, lineWidth: 3)
                    .frame(width: 26, height: 20)
            }
        }
        .frame(width: 44, height: 44)
    }
}
