import SwiftUI

struct SwiftUIBasePage<Content: View>: View {
    let viewModel: PageViewModel
    let content: Content

    @State private var showBusy = false
    @State private var toastMessage: String?

    init(viewModel: PageViewModel, @ViewBuilder content: () -> Content) {
        self.viewModel = viewModel
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
                .padding(.horizontal, CGFloat(NumConstants.PageHMargin))
                .onAppear { viewModel.OnAppearing(); viewModel.OnAppeared() }
                .onDisappear { viewModel.OnDisappearing() }
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }

            if showBusy {
                ProgressView().scaleEffect(1.4).padding().background(.ultraThinMaterial).cornerRadius(12)
            }
            if let msg = toastMessage {
                VStack {
                    Spacer()
                    Text(msg).padding().background(.regularMaterial).cornerRadius(10).padding(.bottom, 28)
                }
            }
        }
    }

    func showLoading(_ busy: Bool) { DispatchQueue.main.async { showBusy = busy } }
    func showToast(_ msg: String) { DispatchQueue.main.async { toastMessage = msg; DispatchQueue.main.asyncAfter(deadline: .now()+3) { toastMessage = nil } } }
}
