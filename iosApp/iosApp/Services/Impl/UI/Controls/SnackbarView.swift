import SharedAppCore
import SwiftUI

class SnackbarManager: ObservableObject
{
    static let shared = SnackbarManager()
    
    @Published var message: String?
    @Published var severity: SeverityType = .info
    @Published var isShowing: Bool = false
    
    func show(message: String, severity: SeverityType)
    {
        self.message = message
        self.severity = severity

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

struct SnackbarView: View
{
    var fontFamily: String? = "Sen"
    var fontFamily2: String? = "Sen-Bold"

    private let cornerRadius: CGFloat = 16
    private let horizontalMargin: CGFloat = 15
    private let topMargin: CGFloat = 15

    var body: some View
    {
        let bgColor = Color(SnackbarColors.shared.GetBackgroundColor(SnackbarManager.shared.severity).ToUIColor())
        let textColor = Color(SnackbarColors.shared.GetTextColor(SnackbarManager.shared.severity).ToUIColor())
        
        ZStack
        {
            // Dim overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { SnackbarManager.shared.close() }
                .transition(.opacity)

            VStack(spacing: 0)
            {
                Spacer().frame(height: topMargin)

                // SNACKBAR CARD
                HStack(spacing: 7)
                {
                    Text(SnackbarManager.shared.message ?? "")
                        .foregroundColor(textColor)
                        .font(textFont)
                        .lineLimit(5)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: { SnackbarManager.shared.close() })
                    {
                        Text("Close")
                            .foregroundColor(textColor)
                            .font(buttonFont)
                    }
                    .frame(minWidth: 80, minHeight: 50)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius).fill(bgColor)
                )

                Spacer() // pushes snackbar to the top
            }
            .padding(.horizontal, horizontalMargin)   // ← EXACT horizontal margin of snackbar
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.25), value: SnackbarManager.shared.isShowing)
    }

    // MARK: - Fonts

    private var textFont: Font
    {
        if let f = fontFamily
        {
            return .custom(f, size: 15)
        }
        return .system(size: 15)
    }

    private var buttonFont: Font
    {
        if let f = fontFamily2
        {
            return .custom(f, size: 16)
        }
        return .system(size: 16)
    }
}
