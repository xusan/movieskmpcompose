import SwiftUI

struct Sui_RectButton<Content: View>: View {
    let normalColor: Color
    let pressedColor: Color
    let onTouchDown: () -> Void
    let onTouchUp: () -> Void
    let content: () -> Content

    @GestureState private var isPressed = false

    var body: some View {
        ZStack {
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 16) // optional, like left/right padding                
        }
        .frame(maxWidth: .infinity)      // fill parent width
        .frame(height: 50)               // fixed height
        .background(isPressed ? pressedColor : normalColor)
        .animation(.easeInOut(duration: 0.12), value: isPressed)
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressed) { _, state, _ in
                    if !state
                    {
                        onTouchDown()
                    }
                    state = true
                }
                .onEnded { _ in
                    onTouchUp()
                }
        )
    }
}

