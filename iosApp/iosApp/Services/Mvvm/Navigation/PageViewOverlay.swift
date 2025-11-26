import SwiftUI
import SharedAppCore

struct PageViewOverlay<Content: View>: View {
    let content: Content
    @State private var busy = false
    @State private var snackbar: (String, SeverityType)?
    
    var body: some View {
        ZStack {
            content

            if busy {
                Color.black.opacity(0.25).ignoresSafeArea()
                ProgressView().scaleEffect(1.5)
            }

            if let (msg, sev) = snackbar {
                VStack {
                    Spacer()
                    SnackbarView(message: msg, severity: sev)
                        .padding(.bottom, 20)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}



struct SnackbarView: View {
    let message: String
    let severity: SeverityType

    private var bg: Color {
        switch severity {
        case .error: return .red
        case .success: return .green
        case .info: return .blue
        default: return .gray
        }
    }

    var body: some View {
        Text(message)
            .padding()
            .background(bg)
            .cornerRadius(10)
            .foregroundColor(.white)
    }
}
