import Foundation
import SwiftUI

/// Keeps the exact same RegisterPageForNavigation signature you asked for:
///   NavRegistrar.RegisterPageForNavigation({ LoginPage() }, { LoginPageViewModel() })
class NavRegistrar {
    private(set) static var navPages: [NavPageInfo] = []

    /// Register a zero-arg SwiftUI page factory and a zero-arg ViewModel factory.
    static func RegisterPageForNavigation<TViewModel: PageViewModel, TPage: View>(
        _ createPage: @escaping () -> TPage,
        _ createViewModel: @escaping () -> TViewModel
    ) {
        let vmName = String(describing: TViewModel.self)
        if navPages.contains(where: { $0.vmName == vmName }) { return }

        let info = NavPageInfo(
            vmName: vmName,
            vmFactory: { createViewModel() },
            pageFactory: { AnyView(createPage()) }
        )
        navPages.append(info)
    }

    /// Create & initialize a NEW VM instance for vmName (call once per navigation push).
    /// This is the only place VM.Initialize should be called.
    static func createVm(vmName: String, parameters: INavigationParameters) -> PageViewModel {
        guard let info = navPages.first(where: { $0.vmName == vmName }) else {
            fatalError("ViewModel '\(vmName)' was not registered for navigation.")
        }
        let vm = info.vmFactory()
        vm.Initialize(parameters: parameters)
        return vm
    }

    /// Build zero-arg page view (the page body). The page expects the ViewModel via @EnvironmentObject.
    static func createPageView(vmName: String) -> AnyView {
        guard let info = navPages.first(where: { $0.vmName == vmName }) else {
            fatalError("Page for ViewModel '\(vmName)' was not registered.")
        }
        return info.pageFactory()
    }

    /// Legacy helper kept for compatibility (returns a wrapper implementing IPage).
    /// Avoid using in render loop; use createVm + createPageView instead.
    static func CreatePage<TViewModel: PageViewModel>(_ type: TViewModel.Type, parameters: INavigationParameters) -> IPage {
        let vmName = String(describing: TViewModel.self)
        return CreatePage(vmName: vmName, parameters: parameters)
    }

    static func CreatePage(vmName: String, parameters: INavigationParameters) -> IPage {
        guard let info = navPages.first(where: { $0.vmName == vmName }) else {
            fatalError("ViewModel '\(vmName)' was not registered for navigation.")
        }
        // create VM and initialize (legacy behavior)
        let vm = info.vmFactory()
        vm.Initialize(parameters: parameters)

        // Build a tiny wrapper IPage that stores vm and page view.
        // SwiftUI pages should receive their VM via @EnvironmentObject(PageViewModelObservable)
        let wrapper = SwiftUIPageWrapper(viewModel: vm, builder: { info.pageFactory() })
        return wrapper
    }
}
