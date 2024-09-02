//
//  CameraView.swift
//  Hex_Cam
//
//  Created by GEET on 9/3/23.
//

import SwiftUI
import AVFoundation
import Combine

struct CameraView: View {
    @StateObject var model = CameraViewModel()
    @Binding var detectedHexColor: String
    @State private var zoomFactor: CGFloat = 1.0

    var body: some View {
        ZStack {
            CameraPreview(model: model)
                .ignoresSafeArea()

            VStack {
                Spacer()
            }
        }
        .onAppear(perform: model.configureCaptureSession)
        .onReceive(Just(model.colorHex)) { newValue in
                    self.detectedHexColor = newValue
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var model: CameraViewModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)

        let previewLayer = AVCaptureVideoPreviewLayer(session: model.captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePinch))
        view.addGestureRecognizer(pinchGesture)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self, model: model)
    }

    class Coordinator: NSObject {
        var view: CameraPreview
        var model: CameraViewModel

        init(_ view: CameraPreview, model: CameraViewModel) {
            self.view = view
            self.model = model
        }

        @objc func handlePinch(_ pinch: UIPinchGestureRecognizer) {
            guard AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified) != nil else {
                print("Could not get capture device")
                return
            }

            guard let videoDeviceInput = model.captureSession.inputs.first as? AVCaptureDeviceInput else {
                print("Could not get video device input")
                return
            }

            let device = videoDeviceInput.device

            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }

                let zoomScale = pinch.scale
                let zoomFactor = device.videoZoomFactor * zoomScale

                if device.minAvailableVideoZoomFactor...device.maxAvailableVideoZoomFactor ~= zoomFactor {
                    device.videoZoomFactor = zoomFactor
                }

                pinch.scale = 1.0

            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
}
