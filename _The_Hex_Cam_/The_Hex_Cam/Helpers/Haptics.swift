//
// Haptics
// The_Hex_Cam 
//
// Created by GEET on 8/26/24
//

import CoreHaptics
import UIKit

func fireworkHapticEffect() {
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    generator.impactOccurred()
    DispatchQueue.global().async {
        for _ in 1...15 {
            usleep(15000)
            DispatchQueue.main.async {
                generator.impactOccurred()
            }
        }
    }
}

func triggerAnimationHaptics() {
    let selectionFeedback = UISelectionFeedbackGenerator()
    selectionFeedback.selectionChanged()

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
        selectionFeedback.selectionChanged()
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()
    }
}
