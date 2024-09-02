//
// AnimatedHexagon
// The_Hex_Cam 
//
// Created by GEET on 08/26/24.
//

import SwiftUI

struct AnimatedHexagon: View {
    var color: Color
    var strokeWidth: CGFloat
    var hexagonScale: CGFloat
    var animationProgress: CGFloat

    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                .frame(width: 300, height: 300)
                .clipShape(MorphingShape(animationProgress: animationProgress))

            MorphingShape(animationProgress: animationProgress)
                .stroke(color, lineWidth: strokeWidth)
        }
        .frame(width: 300, height: 300)
        .scaleEffect(hexagonScale)
        .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1), value: hexagonScale)
    }
}
