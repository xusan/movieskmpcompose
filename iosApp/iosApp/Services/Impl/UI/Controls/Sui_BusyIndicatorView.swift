import SwiftUI

struct Sui_BusyIndicatorView: View
{
    var primaryColor = Color(ColorConstants.PrimaryColor.ToUIColor())
    var bgColor = Color(ColorConstants.BgColor.ToUIColor())
    var textColor = Color(ColorConstants.Gray800.ToUIColor())

    var body: some View
    {
        ZStack
        {
            // Dimmed background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .transition(.opacity)

            // Centered container
            VStack(spacing: 7)
            {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(primaryColor)
                    .frame(width: 32, height: 32)

                Text(BusyIndicatorManager.shared.text ?? "")
                    .font(.custom("Sen-SemiBold", size: 15))
                    .foregroundColor(textColor)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 40)
            .background(bgColor)
            .cornerRadius(16)
            .transition(.scale.combined(with: .opacity))
        }
        .animation(.easeInOut(duration: 0.25), value: BusyIndicatorManager.shared.isShowing)
    }
}

class BusyIndicatorManager: ObservableObject
{
    static let shared = BusyIndicatorManager()
    
    @Published var text: String? = "On it.."
    @Published var isShowing: Bool = false
    
    func show(_ msg: String?)
    {
        if let msg = msg
        {
            text = msg
        }

        // Force re-show (important!)
        withAnimation {
            self.isShowing = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation {
                self.isShowing = true
            }
        }
    }
    
    func close()
    {
        withAnimation {
            isShowing = false
        }
    }
}
