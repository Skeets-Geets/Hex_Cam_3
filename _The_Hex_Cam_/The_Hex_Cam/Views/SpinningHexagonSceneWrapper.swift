//
//  SpinningHexagonSceneWrapper.swift
//  Hex_Cam
//
//  Created by GEET on 10/6/23.
//

import SwiftUI
import SceneKit

struct SpinningHexagonWrapper: View {
    var colorInfo: ColorInfo

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                SpinningHexagonScene(colorInfo: colorInfo)
                    .frame(width: geometry.size.width, height: geometry.size.height)

                Text(colorInfo.hexCode)
                    .foregroundColor(colorInfo.textColor())
                    .font(.system(size: 12))
                    .lineLimit(nil)
                    .minimumScaleFactor(0.5)
                    .frame(width: geometry.size.width * 0.9)
            }
        }
    }
}
