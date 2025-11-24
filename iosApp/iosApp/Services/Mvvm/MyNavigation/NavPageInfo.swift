import Foundation
import SwiftUI

/// Registration record for a ViewModel -> zero-arg SwiftUI Page pair.
final class NavPageInfo {
    let vmName: String
    let vmFactory: () -> PageViewModel
    let pageFactory: () -> AnyView

    init(vmName: String,
         vmFactory: @escaping () -> PageViewModel,
         pageFactory: @escaping () -> AnyView) {
        self.vmName = vmName
        self.vmFactory = vmFactory
        self.pageFactory = pageFactory
    }
}
