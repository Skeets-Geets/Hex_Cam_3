//
//  RainbowBorderView.swift
//  Hex_Cam
//
//  Created by GEET on 10/17/23.
//

import SwiftUI
import UIKit
import DeviceKit

struct BorderShape: Shape {
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addRoundedRect(in: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
        }
    }
}
struct RainbowBorderView: View {
    @State private var gradientStart = UnitPoint(x: 0, y: 0.5)
    @State private var gradientEnd = UnitPoint(x: 1, y: 0.5)
    @State private var borderShape = BorderShape(cornerRadius: 0)

    let animationDuration: TimeInterval = 6.0
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .overlay(
                    borderShape
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "FF0000"), // Red
                                    Color(hex: "FF7F00"), // Orange
                                    Color(hex: "FFFF00"), // Yellow
                                    Color(hex: "00FF00"), // Green
                                    Color(hex: "0000FF"), // Blue
                                    Color(hex: "4B0082"), // Indigo
                                    Color(hex: "9400D3"), // Violet
                                    Color(hex: "FF0000")  // Red (to complete the cycle)
                                ]),
                                startPoint: gradientStart,
                                endPoint: gradientEnd
                            ),
                            lineWidth: 11
                        )
                )
                .onAppear {
                    setupBorderShape()
                }
                .onReceive(timer) { _ in
                    updateGradientPoints()
                }
        }
        .ignoresSafeArea()
    }

    func updateGradientPoints() {
        let time = Date().timeIntervalSinceReferenceDate
        let angle = (time / animationDuration).truncatingRemainder(dividingBy: 1) * 2 * .pi

        gradientStart = UnitPoint(x: 0.5 + 0.5 * cos(angle), y: 0.5 + 0.5 * sin(angle))
        gradientEnd = UnitPoint(x: 0.5 - 0.5 * cos(angle), y: 0.5 - 0.5 * sin(angle))
    }

    func setupBorderShape() {
        let device = Device.current
        let deviceType = device.realDevice

        borderShape.cornerRadius = determineCornerRadius(for: deviceType)
    }

    func determineCornerRadius(for deviceType: Device) -> CGFloat {
        switch deviceType {
        case .iPhone7, .iPhone7Plus,
                .iPhone8, .iPhone8Plus,
                .iPhoneSE2,
                .iPhone12Mini:
            return 20
        case .iPhoneX, .iPhoneXS, .iPhoneXSMax, .iPhoneXR,
                .iPhone11, .iPhone11Pro, .iPhone11ProMax,
                .iPhone12, .iPhone12Pro:
            return 40
        case .iPhone14, .iPhone14Pro:
            return 50
        case .iPhone12ProMax,
                .iPhone13, .iPhone13Pro, .iPhone13ProMax,
                .iPhone14ProMax,
                .iPhone15, .iPhone15Pro, .iPhone15ProMax:
            return 60
        default:
            return 40
        }
    }
}

#if DEBUG
struct RainbowBorderView_Previews: PreviewProvider {
    static var previews: some View {
        RainbowBorderView()
    }
}
#endif
