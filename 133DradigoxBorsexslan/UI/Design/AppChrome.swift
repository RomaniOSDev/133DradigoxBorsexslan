//
//  AppChrome.swift
//  133DradigoxBorsexslan
//

import SwiftUI

enum AppGradients {
    static var screenAmbient: LinearGradient {
        LinearGradient(
            colors: [
                Color.appBackground,
                Color.appAccent.opacity(0.11),
                Color.appPrimary.opacity(0.07)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var screenLower: LinearGradient {
        LinearGradient(
            colors: [
                Color.clear,
                Color.appPrimary.opacity(0.06),
                Color.appAccent.opacity(0.09)
            ],
            startPoint: .center,
            endPoint: .bottom
        )
    }

    static var cardFace: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface,
                Color.appSurface,
                Color.appAccent.opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardRim: LinearGradient {
        LinearGradient(
            colors: [
                Color.appAccent.opacity(0.5),
                Color.appPrimary.opacity(0.18),
                Color.appAccent.opacity(0.22)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryCTA: LinearGradient {
        LinearGradient(
            colors: [
                Color.appPrimary,
                Color.appAccent,
                Color.appPrimary.opacity(0.92)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var progressTrack: LinearGradient {
        LinearGradient(
            colors: [
                Color.appAccent.opacity(0.2),
                Color.appPrimary.opacity(0.12)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var progressFill: LinearGradient {
        LinearGradient(
            colors: [
                Color.appAccent,
                Color.appPrimary.opacity(0.88)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var playfieldPanel: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface,
                Color.appAccent.opacity(0.08),
                Color.appPrimary.opacity(0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var overlayScrim: LinearGradient {
        LinearGradient(
            colors: [
                Color.appBackground.opacity(0.97),
                Color.appPrimary.opacity(0.08),
                Color.appBackground.opacity(0.98)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

extension View {
    /// Full-screen layered gradient (use behind scroll content).
    func appScreenBackground() -> some View {
        background {
            ZStack {
                AppGradients.screenAmbient
                AppGradients.screenLower
            }
            .ignoresSafeArea()
        }
    }

    /// Elevated card: gradient fill, double shadow, gradient stroke.
    func appElevatedCard(cornerRadius: CGFloat = 16) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppGradients.cardFace)
                .shadow(color: Color.appPrimary.opacity(0.14), radius: 18, x: 0, y: 10)
                .shadow(color: Color.appPrimary.opacity(0.06), radius: 4, x: 0, y: 2)
        }
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(AppGradients.cardRim, lineWidth: 1)
        )
    }

    /// Game canvas / modal panel.
    func appPlayfieldShell(cornerRadius: CGFloat = 18) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppGradients.playfieldPanel)
                .shadow(color: Color.appPrimary.opacity(0.18), radius: 20, x: 0, y: 12)
                .shadow(color: Color.appAccent.opacity(0.1), radius: 6, x: 0, y: 3)
        }
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(AppGradients.cardRim, lineWidth: 1.2)
        )
    }

    func appFloatingShadow(radius: CGFloat = 14, y: CGFloat = 8) -> some View {
        shadow(color: Color.appPrimary.opacity(0.12), radius: radius, x: 0, y: y)
            .shadow(color: Color.appAccent.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}
