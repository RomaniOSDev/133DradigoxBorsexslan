//
//  LeaderboardView.swift
//  133DradigoxBorsexslan
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject private var progress: GameProgressStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Personal records")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.appPrimary)
                        .padding(.horizontal, 16)
                    Text("Best scores stored on this device.")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(.horizontal, 16)
                    VStack(spacing: 12) {
                        ForEach(recordRows, id: \.id) { row in
                            RecordRow(row: row)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 16)
            }
            .appScreenBackground()
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var recordRows: [RecordRowModel] {
        var rows: [RecordRowModel] = []
        for activity in ActivityKind.allCases {
            for difficulty in Difficulty.allCases {
                let id = "\(activity.rawValue)_\(difficulty.rawValue)"
                switch activity {
                case .virtualMarathon:
                    if let t = progress.bestMarathonTime(for: difficulty) {
                        rows.append(RecordRowModel(
                            id: id,
                            title: "\(activity.displayTitle) · \(difficulty.displayTitle)",
                            value: String(format: "Best time %.1fs", t),
                            detail: "Lower is better"
                        ))
                    }
                case .precisionPass:
                    if let a = progress.bestPrecisionAccuracy(for: difficulty) {
                        rows.append(RecordRowModel(
                            id: id,
                            title: "\(activity.displayTitle) · \(difficulty.displayTitle)",
                            value: String(format: "Best accuracy %.0f%%", a),
                            detail: "Higher is better"
                        ))
                    }
                case .goalkeeperReflex:
                    if let r = progress.bestKeeperRate(for: difficulty) {
                        rows.append(RecordRowModel(
                            id: id,
                            title: "\(activity.displayTitle) · \(difficulty.displayTitle)",
                            value: String(format: "Best saves %.0f%%", r),
                            detail: "Higher is better"
                        ))
                    }
                }
            }
        }
        if rows.isEmpty {
            rows.append(RecordRowModel(
                id: "empty",
                title: "No records yet",
                value: "Play challenges to populate this list.",
                detail: ""
            ))
        }
        return rows
    }
}

private struct RecordRowModel: Identifiable {
    let id: String
    let title: String
    let value: String
    let detail: String
}

private struct RecordRow: View {
    let row: RecordRowModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(row.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(row.value)
                .font(.body.weight(.medium))
                .foregroundStyle(Color.appAccent)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            if !row.detail.isEmpty {
                Text(row.detail)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedCard(cornerRadius: 14)
    }
}
