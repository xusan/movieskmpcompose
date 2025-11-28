import SwiftUI

struct PrimaryButton: View
{
    let text: String
    let onTap: () -> Void

    var body: some View
    {
        RectButton(
            normalColor: Color(ColorConstants.PrimaryColor.ToUIColor()),
            pressedColor: Color(ColorConstants.PrimaryDark.ToUIColor()),
            onTouchDown: {},
            onTouchUp: onTap
        )
        {
            Text(text)
                .font(.custom("Sen-Bold", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(height: CGFloat(NumConstants.BtnHeight))
        .cornerRadius(CGFloat(NumConstants.BtnHeight) / 2)
    }
}
