import SwiftUI

struct Sui_MultilineTextField: View
{
    @Binding var text: String
    
    var focusedBorderColor: Color = Color(ColorConstants.PrimaryColor.ToUIColor())
    var unfocusedBorderColor: Color = .clear
    var borderWidth: CGFloat = 4
    var cornerRadius: CGFloat = 25
    var fixedHeight: CGFloat = 150

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            // Background + border
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(isFocused ? focusedBorderColor : unfocusedBorderColor, lineWidth: borderWidth)
                .background(Color.white)
                .cornerRadius(cornerRadius)

            // Scrollable multiline text field
//            ScrollView {
                TextEditor(text: $text)
                    .frame(minHeight: fixedHeight, maxHeight: fixedHeight)
                    .padding(.top, 12)
                    .padding(.leading, 15)
                    .padding(.bottom, 10)
                    .padding(.trailing, 15)
                    .font(.custom("Sen", size: 15))
                    .foregroundColor(.black)
                    .focused($isFocused)
            //}
        }
        .frame(height: fixedHeight)
    }
}
