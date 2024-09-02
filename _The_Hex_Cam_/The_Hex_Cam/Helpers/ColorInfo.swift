//
//  ColorInfo.swift
//  Hex_Cam
//
//  Created by Ethan Mackey on 11/7/23.
//  Updated to conform to Codable for saving and loading user colors.
//
import SwiftUI
import Foundation

struct ColorInfo: Codable, Identifiable {
    var id = UUID()
    var colorName: String
    var hexCode: String

    func getSwiftUIColor() -> Color {
        Color(hex: hexCode)
    }

    func getUIColor() -> UIColor {
        UIColor(hex: hexCode)
    }

    func textColor() -> Color {
        getUIColor().isBright ? .black : .white
    }
}
