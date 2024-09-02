//  ContentView.swift
//  HEX-a-CAM
//
//  Created by GEET on 9/3/23.

import SwiftUI

// MARK: ContentView

struct ContentView: View {
    private let shutterFrames: [Image] = (1...21).map { Image("rainShut-\($0)") }

    @State private var capturedColor: Color = Color.white
    @State private var capturedHexCode: String = "#FFFFFF"
    @StateObject private var networkManager = NetworkManager()
    @State private var refreshView: Bool = false
    @State private var savedColors: [ColorInfo] = []

    // Rainbow Shutter
    @State private var shouldShowRainShut = false

    // Camera
    @ObservedObject var cameraViewModel: CameraViewModel
    @State private var showCamera = false

    // GIF
    @State private var showGIF = true

    // Hex
    @State private var animationProgress: CGFloat = 0
    @State private var colorsMenuCurrentFrameIndex = 0
    @State private var hexButtonOffset: CGFloat = 0
    @State private var hexButtonOpacity: Double = 0
    @State private var hexagonRotation: Double = 0  // Added for hexagon rotation
    @State private var hexagonVerticalPosition: CGFloat = 0  // Added for hexagon vertical movement
    @State private var detectedHexColor: String = "#FFFFFF"
    @State private var hexagonScale: CGFloat = 0.01
    @State private var saveButtonOffset: CGFloat = 0
    @State private var saveButtonOpacity: Double = 0
    @State private var showHexagon = false
    @State private var showHexColor = false
    @State private var strokeWidth: CGFloat = 2

    // Button
    @State private var captureButtonScale: CGFloat = 1.0
    @State private var hideSaveButton: Bool = false
    @State private var isButtonClicked = false
    @State private var showCaptureButton = false
    @State private var shutterScale: CGFloat = 1.0

    // Models
    @State private var isLearnMoreVisible = false
    @State private var isMenuVisible = false

    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    private let myColorsFrames: [Image] = (1...19).map { Image("MYcolors-\($0)") }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if showCamera {
                    CameraSection()
                }
                if shouldShowRainShut {
                    ColorChangingComponent(scale: $shutterScale)
                }
                if showGIF {
                    GIFSection(geometry: geometry)
                }
                if isButtonClicked {
                    RainbowBorderView()
                        .ignoresSafeArea()
                    VStack {
                        HexagonSection()
                        ButtonSection(shutterFrames: shutterFrames)
                    }
                }
                if showCaptureButton && showCamera {
                    CaptureButtonSection(geometry: geometry)
                }

                MyColorsMenu(isMenuVisible: $isMenuVisible)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isMenuVisible = false
                            hexagonScale = 1.0
                        }
                    }

                LearnMoreMenu(isVisible: $isLearnMoreVisible, colorCode: $capturedHexCode)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isLearnMoreVisible = false
                            hexagonScale = 1.0
                        }
                    }
            }
        }
        .onAppear {
            showGIF = true
            shutterScale = 0.5
            loadSavedColors()
        }
        .ignoresSafeArea()
    }

    // MARK: GIF

    @ViewBuilder
    private func GIFSection(geometry: GeometryProxy) -> some View {
        ImageViewWrapper(imageName: "hexlaunch") { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    self.showGIF = false
                    self.showCamera = true
                }
                self.showHexColor = true
                self.showCaptureButton = true
                self.shouldShowRainShut = true
            }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .ignoresSafeArea()
    }

    // MARK: Camera

    @ViewBuilder
    private func CameraSection() -> some View {
        CameraView(detectedHexColor: $detectedHexColor)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 4), value: showCamera)
    }

    // MARK: Buttons

    @ViewBuilder
    fileprivate func ButtonSection(shutterFrames: [Image]) -> some View {
        VStack {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.2, blendDuration: 0.5)) {
                    animationProgress = 0
                    hideSaveButton.toggle()
                    if !hideSaveButton {
                        captureButtonScale = 1.0
                    }
                    isMenuVisible.toggle()
                    hexagonScale = isMenuVisible ? 0.1 : 1.0
                }
            }) {
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                        .frame(width: 145, height: 30)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: capturedHexCode), lineWidth: 2)
                        )
                    myColorsFrames[colorsMenuCurrentFrameIndex]
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 15)
                        .onReceive(timer) { _ in
                            colorsMenuCurrentFrameIndex = (colorsMenuCurrentFrameIndex + 1) % myColorsFrames.count
                        }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .opacity(hexButtonOpacity)
            .animation(Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.5), value: hexButtonOffset)
            .padding(.bottom)

            if !isMenuVisible {
                SubtitleButton(text: "Save Color", action: saveColor)

                SubtitleButton(text: "Learn About Your Color", action: learnMore)
            }
        }
            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.5),
                       value: saveButtonOffset)
    }

    private func saveColor() {
        let impactLight = UIImpactFeedbackGenerator(style: .light)
        impactLight.impactOccurred()

        networkManager.fetchColorInfo(for: capturedHexCode)
        let newColorInfo = ColorInfo(colorName: networkManager.colorName, hexCode: capturedHexCode)
        savedColors.append(newColorInfo)

        if let data = try? JSONEncoder().encode(savedColors) {
            UserDefaults.standard.set(data, forKey: PERSISTENCE_KEY)
        }

        withAnimation(.easeInOut(duration: 1.0)) {
            hexagonRotation = 360
            hexagonScale = 1/2
        }
        withAnimation(.easeIn(duration: 0.5).delay(1.0)) {
            hexagonVerticalPosition = -UIScreen.main.bounds.height
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                self.isMenuVisible = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            resetHexagonState()
        }

        triggerAnimationHaptics() // Call the function to trigger haptics during animation
    }

    private func learnMore() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.2, blendDuration: 0.5)) {
            animationProgress = 0
            hideSaveButton.toggle()
            if !hideSaveButton {
                captureButtonScale = 1.0
            }
            isLearnMoreVisible.toggle()
            hexagonScale = isLearnMoreVisible ? 0.1 : 1.0
        }
    }

    private func resetHexagonState() {
        withAnimation(.easeInOut(duration: 0.5)) {
            hexagonRotation = 0
            hexagonScale = 1
            hexagonVerticalPosition = 0
        }
    }

    @ViewBuilder
    private func SubtitleButton(text: String, action: @escaping @MainActor () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: capturedHexCode), lineWidth: 2)
                    )
                Text(text)
                    .font(.system(size: 12))
                    .foregroundColor(Color.white)
                    .padding(.init(top: 6, leading: 6, bottom: 6, trailing: 6))
            }
            .fixedSize(horizontal: true, vertical: true)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(saveButtonOpacity)
    }

    // MARK: Hexagon

    @ViewBuilder
    fileprivate func HexagonSection() -> some View {
        ZStack {
            AnimatedHexagon(
                color: Color(hex: capturedHexCode),
                strokeWidth: strokeWidth,
                hexagonScale: hexagonScale,
                animationProgress: animationProgress
            )
            .id(refreshView ? 0 : 1)
            .scaleEffect(hexagonScale)
            .rotationEffect(.degrees(hexagonRotation))
            .offset(y: hexagonVerticalPosition)
            .animation(.spring(), value: hexagonScale)

            if !isMenuVisible {
                ColorDisplayView(networkManager: networkManager,
                                 detectedHexColor: capturedHexCode,
                                 strokeColor: Color(hex: capturedHexCode),
                                 hexagonScale: hexagonScale)
                .scaleEffect(hexagonScale) // Apply the same scale effect to the text
                .rotationEffect(.degrees(hexagonRotation)) // Apply the same rotation effect to the text
                .offset(y: hexagonVerticalPosition) // Apply the same vertical offset to the text
                .animation(.spring(), value: hexagonScale) // Apply the same animation to the text
            }
        }
    }

    // MARK: Capture Button

    @ViewBuilder
    private func CaptureButtonSection(geometry: GeometryProxy) -> some View {
        Button(action: {
            captureButtonAction()
        }) {
            Image(systemName: isButtonClicked ? "chevron.backward.circle.fill" : "button.programmable")
                .resizable()
                .frame(width: isButtonClicked ? 40 : 60, height: isButtonClicked ? 40 : 60)
                .foregroundColor(isButtonClicked ? .white : .white)
                .scaleEffect(captureButtonScale)
                .shadow(color: isButtonClicked ? .black.opacity(0.4) : .clear, radius: 6, x: 0, y: 0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1), value: captureButtonScale)
        }
        .position(x: geometry.size.width / 2, y: geometry.size.height - geometry.size.height * 0.08)
    }

    private func captureButtonAction() {
        isButtonClicked.toggle()
        cameraViewModel.stopCameraFeed()
        capturedHexCode = detectedHexColor
        refreshView.toggle()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1)) {
            hexagonScale = isButtonClicked ? 1 : 0.001
            strokeWidth = isButtonClicked ? 10 : 2
            shutterScale = isButtonClicked ? 0.001 : 1.0
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 15, blendDuration: 10)) {
            hexButtonOffset = isButtonClicked ? 60 : 0
            hexButtonOpacity = isButtonClicked ? 1 : 0
            saveButtonOffset = isButtonClicked ? 120 : 0
            saveButtonOpacity = isButtonClicked ? 1 : 0
            captureButtonScale = isButtonClicked ? 1.2 : 1.0
        }

        fireworkHapticEffect()
    }

    // MARK: Utilities

    private func loadSavedColors() {
        if let savedData = UserDefaults.standard.data(forKey: PERSISTENCE_KEY),
           let loadedColors = try? JSONDecoder().decode([ColorInfo].self, from: savedData) {
            savedColors = loadedColors
        }
    }
}

// MARK: ColorChangingComponent

struct ColorChangingComponent: View {
    @Binding var scale: CGFloat
    @State private var currentFrameIndex = 0
    @State private var rotationAngle: Double = 0
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    let shutterFrames: [Image] = (1...20).map { Image("rainShut-\($0)") }

    var body: some View {
        shutterFrames[currentFrameIndex]
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .onReceive(timer) { _ in
                if !shutterFrames.isEmpty {
                    currentFrameIndex = (currentFrameIndex + 1) % shutterFrames.count
                }
            }
            .rotationEffect(.degrees(rotationAngle))
            .animation(.linear(duration: 5).repeatForever(autoreverses: false), value: rotationAngle)
            .animation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1), value: scale)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
            }
    }
}

// MARK: Preview

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let cameraViewModel = CameraViewModel()
        ContentView(cameraViewModel: cameraViewModel)
    }
}
#endif
