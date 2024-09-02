//
//  The_Hex_CamApp.swift
//  The_Hex_Cam
//
//  Created by Ethan Mackey on 12/11/23.
//

import SwiftUI

@main
struct The_Hex_CamApp: App {
    var cameraViewModel = CameraViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(cameraViewModel: cameraViewModel)
        }
    }
}
