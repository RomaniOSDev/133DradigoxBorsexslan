//
//  ContentView.swift
//  133DradigoxBorsexslan
//
//  Created by Роман Главацкий on 04.04.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var progress = GameProgressStore()

    var body: some View {
        Group {
            if progress.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(progress)
    }
}

#Preview {
    ContentView()
}
