//
//  SpinningHexagonScene.swift
//  Hex_Cam
//
//  Created by GEET on 10/4/23.
//

import SwiftUI
import SceneKit

struct SpinningHexagonScene: UIViewRepresentable {
    var colorInfo: ColorInfo
    let hexagonNodeName = "HexagonMetal"

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = createHexagonScene(with: colorInfo.getUIColor())
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = UIColor.clear
        sceneView.allowsCameraControl = false
        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        guard let hexagonNode = uiView.scene?.rootNode.childNode(withName: hexagonNodeName, recursively: true) else {
            return
        }
        hexagonNode.geometry?.firstMaterial?.diffuse.contents = colorInfo.getUIColor()
    }

    private func createHexagonScene(with color: UIColor) -> SCNScene {
        guard let sceneURL = Bundle.main.url(forResource: "HexagonMetal", withExtension: "scn"),
              let scene = try? SCNScene(url: sceneURL, options: nil) else {
            return SCNScene()
        }
        return scene
    }
}
