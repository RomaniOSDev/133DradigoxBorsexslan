//
//  LockGlyph.swift
//  133DradigoxBorsexslan
//

import SwiftUI

struct LockGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        let body = CGRect(x: w * 0.2, y: h * 0.42, width: w * 0.6, height: h * 0.5)
        p.addRoundedRect(in: body, cornerSize: CGSize(width: w * 0.12, height: w * 0.12))
        let arch = CGRect(x: w * 0.28, y: h * 0.18, width: w * 0.44, height: h * 0.38)
        p.addArc(center: CGPoint(x: arch.midX, y: arch.maxY), radius: arch.width / 2, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        return p
    }
}
