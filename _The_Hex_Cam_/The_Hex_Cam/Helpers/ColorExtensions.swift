//
//  ColorExtensions.swift
//  Hex_Cam
//
//  Created by GEET on 10/9/23.
//

import Foundation
import SwiftUI
import UIKit

extension UIColor {
    // Initialize UIColor with SwiftUI Color
    convenience init(_ color: SwiftUI.Color) {
        let components = color.components()
        self.init(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }

    // Initialize UIColor with a hex string
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        let int: UInt64 = {
            if let int = Int(hex, radix: 16) {
                UInt64(int)
            } else {
                UInt64.zero
            }
        }()
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0) // Default color (transparent black) for invalid input
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

    // Add this computed property to check the brightness
    var isBright: Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: nil)

        // Formula for brightness
        let brightness = 0.299 * red + 0.587 * green + 0.114 * blue
        return brightness > 0.5
    }
}

extension Color {
    // Extract RGB components from SwiftUI Color
    func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let int: UInt64 = {
            if let int = Int(hex, radix: 16) {
                UInt64(int)
            } else {
                UInt64.zero
            }
        }()
        let r, g, b: UInt64
        switch hex.count {
        case 8, // ARGB
             6: // RGB
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0) // Default color (transparent black) for invalid input
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }
}
