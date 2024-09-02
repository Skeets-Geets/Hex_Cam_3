//
//  MyColorsMenu.swift
//  Hex_Cam
//
import SwiftUI

struct HexagonRow: View {
    var colorInfo: ColorInfo
    @Binding var selectedIndex: UUID?
    @State private var rotationAngle: Double = 0
    @State private var buttonOffset: CGFloat = -40
    @State private var buttonOpacity: Double = 0
    var onDelete: (() -> Void)?

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            SpinningHexagonWrapper(colorInfo: colorInfo)
                .frame(width: selectedIndex == colorInfo.id ? 120 : 70, height: selectedIndex == colorInfo.id ? 120 : 70)
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedIndex = selectedIndex == colorInfo.id ? nil : colorInfo.id
                    }
                }

            if selectedIndex == colorInfo.id {
                VStack {
                    Text(colorInfo.colorName)
                        .font(.system(size: 18, weight: .bold))
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .offset(y: buttonOffset)
                        .opacity(buttonOpacity)
                        .transition(.scale)
                        .onAppear {
                            withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.6).delay(0.5)) {
                                buttonOffset = 0
                                buttonOpacity = 1
                            }
                        }
                        .onDisappear {
                            withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.6)) {
                                buttonOffset = 30
                                buttonOpacity = 0
                            }
                        }

                    Button(action: { onDelete?() }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .foregroundColor(.red)
                            .frame(width: 24, height: 24)
                            .offset(y: buttonOffset)
                            .opacity(buttonOpacity)
                            .transition(.scale)
                            .onAppear {
                                withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.6).delay(0.6)) {
                                    buttonOffset = 0
                                    buttonOpacity = 1
                                }
                            }
                            .onDisappear {
                                withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.6)) {
                                    buttonOffset = 30
                                    buttonOpacity = 0
                                }
                            }
                    }
                    .padding(.top, 2)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .transition(.scale)
    }
}

struct MyColorsMenu: View {
    @Binding var isMenuVisible: Bool

    @State private var savedColors: [ColorInfo] = []
    @State private var selectedIndex: UUID?
    @State private var scrollToTop: Bool = false  // State to trigger scrolling to the top

    var body: some View {
        if isMenuVisible {
            AnimatedMenuView { geometry, scrollViewProxy in
                VStack {
                    Text("My Colors")
                        .font(.system(size: 38, weight: .light, design: .default))
                        .bold()
                        .foregroundColor(.white)

                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 20)], spacing: 20) {
                            ForEach(savedColors, id: \.id) { colorInfo in
                                HexagonRow(colorInfo: colorInfo, selectedIndex: $selectedIndex, onDelete: {
                                    withAnimation {
                                        if let index = savedColors.firstIndex(where: { $0.id == colorInfo.id }) {
                                            savedColors.remove(at: index)
                                            saveColors()
                                        }
                                    }
                                })
                                .id(colorInfo.id)
                                .frame(height: selectedIndex == colorInfo.id ? 260 : 130)
                                .padding(20)
                            }
                        }
                        .padding(.top, geometry.safeAreaInsets.top)
                        .padding()
                    }

                    Spacer()

                    Button("Close") {
                        isMenuVisible = false
                    }
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(50)
                }
                .padding(.vertical, 50)
                .onChange(of: scrollToTop) { _ in
                    if scrollToTop {
                        if let first = savedColors.first {
                            withAnimation {
                                scrollViewProxy.scrollTo(first.id, anchor: .top)
                            }
                        }
                        scrollToTop = false  // Reset the trigger
                    }
                }
            }
            .onAppear() {
                loadSavedColors()
            }
        }
    }

    private func saveColors() {
        if let encodedData = try? JSONEncoder().encode(savedColors) {
            UserDefaults.standard.set(encodedData, forKey: PERSISTENCE_KEY)
        }
    }

    private func loadSavedColors() {
        if let savedData = UserDefaults.standard.data(forKey: PERSISTENCE_KEY),
           let loadedColors = try? JSONDecoder().decode([ColorInfo].self, from: savedData) {
            savedColors = loadedColors.reversed() // Reverse the order of colors here
            print("Loaded Colors:", savedColors.map(\.colorName))  // Confirm order
        }
    }
}

#if DEBUG
struct MyColorsMenu_Previews: PreviewProvider {
    static var previews: some View {
        MyColorsMenu(isMenuVisible: .constant(true))
    }
}
#endif
