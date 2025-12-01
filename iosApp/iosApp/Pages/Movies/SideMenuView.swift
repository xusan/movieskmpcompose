import SwiftUI

struct SideMenuView: View
{
    // Callbacks from parent view
    let onShareLogs: () -> Void
    let onLogout: () -> Void

    private var versionText: String
    {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version: \(short) (\(build))"
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 2)
        {
            // Top spacer (60)
            Spacer()
                .frame(height: 60)

            // Share logs button
            Sui_SvgIconTextButton(
                normalColor: .white,
                pressedColor: Color(ColorConstants.PrimaryColor2.ToUIColor()),
                onTouchDown: {},
                onTouchUp: { onShareLogs() },
                icon: "logout.svg",
                text: "Share Logs",
                font: Font.custom("Sen", size: 22)
            )
            .frame(height: 60)

            // Logout button
            Sui_SvgIconTextButton(
                normalColor: .white,
                pressedColor: Color(ColorConstants.PrimaryColor2.ToUIColor()),
                onTouchDown: {},
                onTouchUp: { onLogout() },
                icon: "logout.svg",
                text: "Logout",
                font: Font.custom("Sen", size: 22)
            )
            .frame(height: 60)

            // Flexible Spacer
            Spacer()

            // Version text aligned bottom-right
            HStack
            {
                Spacer()
                Text(versionText)
                    .font(Font.custom("Sen-SemiBold", size: 12))
                    .foregroundColor(Color(ColorConstants.LabelColor.ToUIColor()))
            }
            .padding(.bottom, 50)
            .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
    }
}
