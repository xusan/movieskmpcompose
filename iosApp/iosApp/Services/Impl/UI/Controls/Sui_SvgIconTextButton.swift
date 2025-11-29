import SwiftUI

struct Sui_SvgIconTextButton: View
{
    let normalColor: Color
    let pressedColor: Color

    // callbacks
    let onTouchDown: () -> Void
    let onTouchUp: () -> Void

    // main properties
    let icon: String
    let text: String
    let font: Font
    let horizintalPadding: CGFloat = 20
    var spacing: CGFloat = 8.0
    var iconSize: CGFloat = 34.0
    var textColor: Color = Color(ColorConstants.DefaultTextColor.ToUIColor())
    var isVertical: Bool = false
    var horizontalAlignment = Alignment.leading
    var corner: CGFloat = 0
    var height: CGFloat = 60

    var body: some View
    {
        Sui_RectButton(
            normalColor: normalColor,
            pressedColor: pressedColor,
            onTouchDown: onTouchDown,
            onTouchUp: onTouchUp
        )
        {
            HStackOrVStack
        }
        .frame(height: height)
        .cornerRadius(corner)      // pill or square
        .padding(.horizontal, 0)
    }

    // MARK: - Layout
    @ViewBuilder
    private var HStackOrVStack: some View {
        if isVertical
        {
            VStack(spacing: spacing)
            {
                iconView
                textView
            }
            .frame(maxWidth: .infinity, alignment: horizontalAlignment)
            .padding(.horizontal, horizintalPadding)
        }
        else
        {
            HStack(spacing: spacing) {
                iconView
                textView
            }
            .frame(maxWidth: .infinity, alignment: horizontalAlignment)
            .padding(.horizontal, horizintalPadding)
        }
    }

    // MARK: - Subviews

    private var iconView: some View
    {
        Sui_SvgImageView(svgFileName: icon)
            .frame(width: iconSize, height: iconSize)
    }

    private var textView: some View
    {
        Text(text)
            .font(font)
            .foregroundColor(textColor)
    }
}
