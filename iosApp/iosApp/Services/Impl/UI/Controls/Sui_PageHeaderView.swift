import SwiftUI

struct Sui_PageHeaderView: View
{
    let title: String
    let leftIcon: String?
    let rightIcon: String?
    
    let onLeftTap: (() -> Void)?
    let onRightTap: (() -> Void)?
    
    // header sizing constants — same as your ASDK values
    let hPadding: CGFloat = CGFloat(NumConstants.PageHeaderHPadding)
    let vPadding: CGFloat = CGFloat(NumConstants.PageHeaderVPadding)
    
    var body: some View
    {
        HStack(spacing: 0)
        {
            // LEFT area
            if let leftIcon = leftIcon
            {
                Sui_SvgCircleButton(svgFileName: leftIcon, action: onLeftTap ?? { print("Page header left button tapped") })
            }
            else
            {
                emptySpacerIfNeeded(side: .left)
            }
            
            // TITLE (flex grow)
            Spacer()
            
            Text(title)
                .font(.custom("Sen", size: 18))
                .foregroundColor(Color(ColorConstants.DefaultTextColor.ToUIColor()))
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer()
            
            // RIGHT area
            if let rightIcon = rightIcon
            {
                Sui_SvgCircleButton(svgFileName: rightIcon, action: onRightTap ?? { print("Page header right button tapped") })
            }
            else
            {
                emptySpacerIfNeeded(side: .right)
            }
        }
        .padding(.horizontal, hPadding)
        .padding(.vertical, vPadding)
        .background(Color(ColorConstants.HeaderBgColor.ToUIColor()))
    }
            
    private func emptySpacerIfNeeded(side: SpacerSide) -> some View
    {
        Group
        {
            if (side == .left && rightIcon != nil) ||
                (side == .right && leftIcon != nil) {
                // Need a spacer equal to button width
                // Here we use 44x44 as a typical hit target.
                // If you want exact icon size, pass it in.
                Color.clear.frame(width: 44, height: 44)
            }
            else
            {
                EmptyView()
            }
        }
    }
    
    enum SpacerSide { case left, right }
}
