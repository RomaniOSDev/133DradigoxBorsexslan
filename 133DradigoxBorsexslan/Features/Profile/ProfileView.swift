//
//  ProfileView.swift
//  133DradigoxBorsexslan
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var progress: GameProgressStore
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    settingsEntrySection
                    statsSection
                    achievementsSection
                    resetSection
                }
                .padding(.vertical, 16)
            }
            .appScreenBackground()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Reset all progress?", isPresented: $showResetConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    progress.resetAllProgress()
                }
            } message: {
                Text("This clears stars, unlocks, statistics, and onboarding status on this device.")
            }
        }
    }

    private var settingsEntrySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("App")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appPrimary)
                .padding(.horizontal, 16)
            NavigationLink {
                SettingsView()
            } label: {
                HStack {
                    Text("Settings")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appAccent)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, minHeight: 44)
                .appElevatedCard(cornerRadius: 14)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appPrimary)
                .padding(.horizontal, 16)
            VStack(spacing: 10) {
                statRow(label: "Total stars", value: "\(progress.totalStarsCollected())")
                statRow(label: "Completed sessions", value: "\(progress.totalActivitiesPlayed)")
                statRow(label: "Total time in play", value: formatDuration(progress.totalPlaySeconds))
            }
            .padding(.horizontal, 16)
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
        .padding(14)
        .appElevatedCard(cornerRadius: 12)
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appPrimary)
                .padding(.horizontal, 16)
            let unlocked = progress.unlockedAchievementDefinitions()
            if unlocked.isEmpty {
                Text("Complete challenges to unlock achievements.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.horizontal, 16)
            } else {
                VStack(spacing: 10) {
                    ForEach(unlocked) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Text(item.detail)
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                                .lineLimit(3)
                                .minimumScaleFactor(0.7)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appElevatedCard(cornerRadius: 12)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var resetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Data")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appPrimary)
                .padding(.horizontal, 16)
            Button {
                showResetConfirm = true
            } label: {
                Text("Reset All Progress")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppGradients.primaryCTA)
                            .shadow(color: Color.appPrimary.opacity(0.35), radius: 10, x: 0, y: 6)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.appTextPrimary.opacity(0.2), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    private func formatDuration(_ t: TimeInterval) -> String {
        guard t > 0 else { return "0m 00s" }
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%dm %02ds", m, s)
    }
}
