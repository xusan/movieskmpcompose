import SwiftUI

/// Wraps a SwiftUI View so it can be used as IPage for KMP navigation.
/// This replaces old UIKit ASDKViewController pages.
final class SwiftUIPageWrapper: IPage {
    var ViewModel: PageViewModel
       private let builder: () -> AnyView

       init(viewModel: PageViewModel, builder: @escaping () -> AnyView) {
           self.ViewModel = viewModel
           self.builder = builder
       }

       func view() -> AnyView {
           builder()
       }
}
