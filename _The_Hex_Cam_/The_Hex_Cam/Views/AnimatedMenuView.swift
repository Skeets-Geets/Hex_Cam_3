//
// AnimatedMenuView
// The_Hex_Cam 
//
// Created on GEET on 8/26/24.
//

import SwiftUI

struct AnimatedMenuView<Content> : View where Content : View {
    private let content: (_ geometry: GeometryProxy, _ scrollViewProxy: ScrollViewProxy) -> Content

    @State private var menuWidth: CGFloat = 140
    @State private var menuHeight: CGFloat = 40
    @State private var menuCornerRadius: CGFloat = 20.0
    @State private var menuOffsetY: CGFloat = 1
    @State private var isAnimating: Bool = false

    @inlinable public init(@ViewBuilder content: @escaping (_ geometry: GeometryProxy, _ scrollViewProxy: ScrollViewProxy) -> Content) {
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollViewProxy in
                ZStack {
                    Color.clear.opacity(0.0).edgesIgnoringSafeArea(.all).zIndex(2)

                    content(geometry, scrollViewProxy)
                        .frame(width: menuWidth, height: menuHeight, alignment: .top)
                        .background(.black)
                        .cornerRadius(menuCornerRadius)
                        .padding(.bottom, 1)
                        .onAppear {
                            menuWidth = 140
                            menuHeight = 20
                            menuCornerRadius = 100.0
                            guard !isAnimating else { return }
                            isAnimating = true

                            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.3)) {
                                menuWidth = geometry.size.width - 8
                                menuCornerRadius = 20.0
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.75, blendDuration: 1.5)) {
                                    menuHeight = geometry.size.height - 9
                                    menuOffsetY = geometry.size.height / 150
                                    menuCornerRadius = 55
                                }
                                isAnimating = false
                            }
                        }
                }
            }
        }
        .ignoresSafeArea()
        .background(.black.opacity(0.5))
    }
}
