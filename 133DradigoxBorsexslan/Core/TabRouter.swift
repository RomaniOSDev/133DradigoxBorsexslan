//
//  TabRouter.swift
//  133DradigoxBorsexslan
//

import Combine
import SwiftUI

final class TabRouter: ObservableObject {
    @Published var selectedTab: Int = 0

    func openChallenges() {
        selectedTab = 1
    }

    func openLeaderboard() {
        selectedTab = 2
    }

    func openProfile() {
        selectedTab = 3
    }
}
