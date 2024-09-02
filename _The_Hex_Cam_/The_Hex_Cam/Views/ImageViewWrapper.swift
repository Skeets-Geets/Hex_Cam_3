//
// ImageViewWrapper
// The_Hex_Cam 
//
// Created by GEET on 8/26/24.
//

import SwiftUI

struct ImageViewWrapper: UIViewRepresentable {
    var imageName: String
    var completion: ((Double) -> Void)?

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.loadGif(from: imageName) { duration in
            completion?(duration)
        }
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: ImageViewWrapper
        init(_ parent: ImageViewWrapper) {
            self.parent = parent
        }

        @objc func handleHapticFeedback() {
            let generator = UINotificationFeedbackGenerator()
            for _ in 1...6 {
                generator.notificationOccurred(.success)
                usleep(200000)
            }
        }
    }
}
