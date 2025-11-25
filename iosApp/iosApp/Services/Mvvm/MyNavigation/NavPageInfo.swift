import SwiftUI

final class NavPageInfo {
    let vmName: String
    let createVm: () -> PageViewModel
    let createPage: () -> AnyView

    init(
        vmName: String,
        createVm: @escaping () -> PageViewModel,
        createPage: @escaping () -> AnyView
    ) {
        self.vmName = vmName
        self.createVm = createVm
        self.createPage = createPage
    }
}
