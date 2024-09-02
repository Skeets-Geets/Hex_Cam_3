//
//  ColorDisplayView.swift
//  Hex_Cam
//
//  Created by GEET on 9/29/23.
//

import SwiftUI

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: effect)
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}

struct StrokedButton: View {
    var title: String
    var action: () -> Void
    var strokeColor: Color

    var body: some View {
        Button(action: action) {
            ZStack {
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                    .frame(width: 145, height: 30)
                    .cornerRadius(30)
                Text(title)
                    .foregroundColor(.primary)
                    .bold()
                    .kerning(2.0)
            }
            .overlay(RoundedRectangle(cornerRadius: 30)
                        .stroke(strokeColor, lineWidth: 2))
        }
    }
}

struct ColorDisplayView: View {
    @ObservedObject var networkManager: NetworkManager
    var detectedHexColor: String
    var strokeColor: Color
    var hexagonScale: CGFloat // Add this to pass the hexagon scale

    private var textScale: CGFloat {
        // Adjust the formula as needed to get the desired effect
        max(hexagonScale, 0.5) // Ensures text doesn't become too small
    }

    var body: some View {
        VStack {
            if let colorImage = networkManager.colorImage {
                Image(uiImage: colorImage)
                    .resizable()
                    .frame(width: 100, height: 100)
            }
            Text(networkManager.colorName)
                .bold()
                .font(.system(size: 35, weight: .semibold, design: .default))
                .lineLimit(1) // Ensures text doesn't wrap to a new line
                .truncationMode(.tail) // Truncate at the end if too long
                .frame(maxWidth: 280) // Limit the width of the text
                .padding(.top, 40)
                .kerning(2.0)
                .scaleEffect(textScale)

            Text(detectedHexColor)
                .bold()
                .font(.system(size: 22, weight: .thin, design: .default))
                .padding(.top, 25)
                .kerning(2.0)
                .scaleEffect(textScale)
        }
        .padding(.horizontal)
        .onAppear {
            networkManager.fetchColorInfo(for: detectedHexColor)
        }
        .zIndex(2)
    }
}
