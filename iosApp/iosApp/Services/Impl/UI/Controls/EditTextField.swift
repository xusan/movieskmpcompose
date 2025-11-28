import SwiftUI

struct EditTextField: View
{
    @Binding var text: String
    var placeholder: String
    var fontSize: CGFloat = 15
    var fontFamily: String = "Sen"

    // MARK: - Configurable
    var normalBorderColor: Color = .clear
    var focusedBorderColor: Color = Color(ColorConstants.PrimaryColor.ToUIColor())
    var minHeight: CGFloat = 45
    var horizontalPadding: CGFloat = 20

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .leading) {

            // Custom placeholder
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.leading, horizontalPadding)
                    .font(.custom(fontFamily, size: fontSize))
            }

            HStack(spacing: 0) {

                Spacer().frame(width: horizontalPadding)

                TextField("", text: $text, onEditingChanged: { _ in })
                    .focused($isFocused)
                    .font(.custom(fontFamily, size: fontSize))
                    .foregroundColor(.black)
                    .submitLabel(.done)
                    .onSubmit { isFocused = false }

                Spacer().frame(width: horizontalPadding) // right-side padding
            }
        }
        .frame(height: minHeight)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: minHeight / 2)
                .stroke(isFocused ? focusedBorderColor : normalBorderColor, lineWidth: 2)
        )
        .cornerRadius(minHeight / 2)
    }
}
