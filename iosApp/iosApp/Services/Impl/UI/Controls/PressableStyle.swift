
import SwiftUI

struct PressableStyle: ButtonStyle
{
    let pressedColor: Color
    let normalColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? pressedColor : normalColor)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
