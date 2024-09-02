//
//  MyScene.swift
//  Hex_Cam
//
//  Created by GEET on 10/4/23.
//

import Foundation
import SpriteKit

class MyScene: SKScene {
    var hexagon: SKShapeNode!
    var rotationAngle: CGFloat = 0.0
    var initialHexagonPositions: [Int: CGPoint] = [:]
    var colorInfo: ColorInfo

    init(size: CGSize, colorInfo: ColorInfo) {
        self.colorInfo = colorInfo
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        func point(from index: Int) -> CGPoint {
            let theta = CGFloat(index) * (2.0 * .pi / CGFloat(NUMBER_OF_SIDES))
            let x = cos(theta) * 100
            let y = sin(theta) * 100
            return CGPoint(x: x, y: y)
        }

        self.backgroundColor = .clear

        let path = UIBezierPath()
        (0...NUMBER_OF_SIDES).forEach {
            let point = point(from: $0)
            if path.isEmpty {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.close()

        hexagon = SKShapeNode(path: path.cgPath)
        hexagon.fillColor = UIColor(hex: colorInfo.hexCode)
        hexagon.lineWidth = 0
        hexagon.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        addChild(hexagon)

        let hexagonID = 1
        initialHexagonPositions[hexagonID] = hexagon.position
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)
        let dx = location.x - previousLocation.x
        rotationAngle += dx * 0.05
        print("dx: \(dx), rotationAngle: \(rotationAngle)")
        hexagon.xScale = cos(rotationAngle)
    }
}
