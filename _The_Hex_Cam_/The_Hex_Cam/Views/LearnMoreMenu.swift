//
// LearnMoreMenu
// The_Hex_Cam
//
// Created by GEET on 08/26/24.
//

import SwiftUI

struct LearnMoreMenu: View {
    @Binding var isVisible: Bool
    @Binding var colorCode: String

    var body: some View {
        if isVisible {
            AnimatedMenuView { _, _ in
                VStack {
                    Text("Test")
                        .font(.system(size: 38, weight: .light, design: .default))
                        .bold()
                        .foregroundColor(.white)
                    Text(colorCode)
                        .font(.system(size: 28, weight: .light, design: .default))
                        .foregroundColor(.white)



                    Spacer()

                    Button("Close") {
                        isVisible = false
                    }
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(50)
                }
                .padding(.top, 50)
            }
        }
    }
}

#if DEBUG
struct LearnMoreMenu_Previews: PreviewProvider {
    static var previews: some View {
        LearnMoreMenu(isVisible: .constant(true), colorCode: .constant("#FFFFFF"))
    }
}
#endif
