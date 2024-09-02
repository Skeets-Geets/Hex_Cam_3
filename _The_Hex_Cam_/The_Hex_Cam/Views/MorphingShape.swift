//
// MorphingShape
// The_Hex_Cam 
//
// Created by GEET on 8/26/24.
//

import SwiftUI

struct MorphingShape: Shape {
    var animationProgress: CGFloat

    func path(in rect: CGRect) -> Path {
        if animationProgress <= 0.5 {
            return hexagonPath(in: rect, progress: animationProgress * 2)
        } else {
            return roundedRectPath(in: rect, progress: (animationProgress - 0.5) * 2)
        }
    }

    private func hexagonPath(in rect: CGRect, progress: CGFloat) -> Path {
        func point(for index: Int) -> CGPoint {
            let angle = 2.0 * .pi / Double(NUMBER_OF_SIDES)
            let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
            let radius = min(rect.width, rect.height) / 2

            let indexAngle = Double(index) * angle
            let x = center.x + radius * CGFloat(cos(indexAngle))
            let y = center.y + radius * CGFloat(sin(indexAngle))
            return CGPoint(x: x, y: y)
        }

        var path = Path()
        (0..<NUMBER_OF_SIDES).forEach {
            let point = point(for: $0)
            if path.isEmpty {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.closeSubpath()
        return path
    }

    private func roundedRectPath(in rect: CGRect, progress: CGFloat) -> Path {
        let cornerRadius = interpolate(from: 0, to: rect.width / 4, progress: progress)
        return RoundedRectangle(cornerRadius: cornerRadius).path(in: rect)
    }

    private func interpolate(from: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
        return from * (1 - progress) + to * progress
    }
}
