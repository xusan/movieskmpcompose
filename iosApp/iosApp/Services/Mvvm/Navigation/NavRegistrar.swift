import SwiftUI

class NavRegistrar {

    private(set) static var navPages: [NavPageInfo] = []

    static func RegisterPageForNavigation<TVM: PageViewModel, TPage: View>(
        _ createPage: @escaping () -> TPage,
        _ createViewModel: @escaping () -> TVM
    )
    {
        let vmName = String(describing: TVM.self)

        if navPages.contains(where: { $0.vmName == vmName }) {
            return
        }

        navPages.append(
            NavPageInfo(
                vmName: vmName,
                createVm: { createViewModel() },
                createPage: { AnyView(createPage()) }
            )
        )
    }

    static func GetPageInfo(vmName: String) -> NavPageInfo
    {
        guard let info = navPages.first(where: { $0.vmName == vmName }) else {
            fatalError("Page not registered for VM: \(vmName)")
        }
        return info
    }
}
