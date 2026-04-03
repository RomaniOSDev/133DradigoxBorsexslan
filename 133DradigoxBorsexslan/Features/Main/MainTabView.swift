//
//  MainTabView.swift
//  133DradigoxBorsexslan
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var tabRouter = TabRouter()

    var body: some View {
        TabView(selection: $tabRouter.selectedTab) {
            HomeView()
                .environmentObject(tabRouter)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            ChallengesRootView()
                .tabItem {
                    Label("Challenges", systemImage: "sportscourt.fill")
                }
                .tag(1)
            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: "list.number")
                }
                .tag(2)
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(Color.appPrimary)
    }
}
