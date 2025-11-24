import SwiftUI
import Foundation

@MainActor
final class SwiftUIPageNavigationService: NSObject, IPageNavigationService, ObservableObject {

    static let shared = SwiftUIPageNavigationService()

    @Published var path = NavigationPath()
    @Published private(set) var entries: [PageEntry] = []

    /// map entry.id -> created VM instance
    private var vmStore: [UUID: PageViewModel] = [:]

    private override init() { super.init() }

    // MARK: - IPageNavigationService conformance

    var CanNavigateBack: Bool { entries.count > 1 }

    func GetCurrentPage() -> (any IPage)? { nil } // not used in SwiftUI host
    func GetCurrentPageModel() -> PageViewModel? { entries.last.flatMap { vmStore[$0.id] } }
    func GetNavStackModels() -> [PageViewModel] { entries.compactMap { vmStore[$0.id] } }
    func GetRootPageModel() -> PageViewModel? { entries.first.flatMap { vmStore[$0.id] } }

    func Navigate(name: String, parameters: (any INavigationParameters)?, useModalNavigation: Bool, animated: Bool, wrapIntoNav: Bool) async throws {
        let params = parameters ?? NavigationParameters()
        let info = UrlNavigationHelper.companion.Parse(url: name)

        if info.isPush {
            try await push(vmName: name, params: params, animated: animated)
        } else if info.isPop {
            try await pop(params: params, animated: animated)
        } else if info.isMultiPop {
            try await multiPop(url: name, params: params, animated: animated)
        } else if info.isMultiPopAndPush {
            try await multiPopAndPush(url: name, params: params, animated: animated)
        } else if info.isPushAsRoot {
            try await pushRoot(url: name, params: params, animated: animated)
        } else if info.isMultiPushAsRoot {
            try await multiPushRoot(url: name, params: params, animated: animated)
        } else {
            throw NSError(domain: "Navigation", code: -1, userInfo: [NSLocalizedDescriptionKey: "Navigation case not implemented."])
        }
    }

    func NavigateToRoot(parameters: (any INavigationParameters)?) async throws {
        try await popToRoot(params: parameters ?? NavigationParameters())
    }

    // MARK: - Navigation implementations

    private func push(vmName: String, params: INavigationParameters, animated: Bool) async throws {
        // create & initialize VM exactly once
        let vm = NavRegistrar.createVm(vmName: vmName, parameters: params)

        // lifecycle
        vm.OnNavigatedTo(parameters: params)
        vm.OnAppeared()

        // create entry & store vm
        let entry = PageEntry(vmName: vmName)
        vmStore[entry.id] = vm
        entries.append(entry)

        withAnimation(animated ? .easeInOut : nil) {
            path.append(entry)
        }
    }

    private func pop(params: INavigationParameters, animated: Bool) async throws {
        guard entries.count > 1 else { return }

        let removed = entries.removeLast()
        // lifecycle + destroy
        if let vm = vmStore[removed.id] {
            vm.OnNavigatedFrom(parameters: NavigationParameters())
            vm.Destroy()
            vmStore[removed.id] = nil
        }

        withAnimation(animated ? .easeInOut : nil) {
            path.removeLast()
        }

        // notify new top
        if let top = entries.last, let topVm = vmStore[top.id] {
            topVm.OnNavigatedTo(parameters: params)
        }
    }

    private func multiPop(url: String, params: INavigationParameters, animated: Bool) async throws {
        let popCount = url.split(separator: "/").count - 1
        for _ in 0..<popCount where entries.count > 1 {
            let removed = entries.removeLast()
            vmStore[removed.id]?.Destroy()
            vmStore[removed.id] = nil
            path.removeLast()
        }
        if let top = entries.last, let topVm = vmStore[top.id] {
            topVm.OnNavigatedTo(parameters: params)
        }
    }

    private func multiPopAndPush(url: String, params: INavigationParameters, animated: Bool) async throws {
        let popCount = url.split(separator: "/").count - 1
        for _ in 0..<popCount where entries.count > 1 {
            let removed = entries.removeLast()
            vmStore[removed.id]?.Destroy()
            vmStore[removed.id] = nil
            path.removeLast()
        }
        let newVmName = url.replacingOccurrences(of: "../", with: "")
        try await push(vmName: newVmName, params: params, animated: animated)
    }

    private func pushRoot(url: String, params: INavigationParameters, animated: Bool) async throws {
        let vmName = url
               .replacingOccurrences(of: "/", with: "")
            

           // destroy old
           entries.forEach { vmStore[$0.id]?.Destroy() }
           vmStore.removeAll()

           // 🚨 new entry and new VM
           let newEntry = PageEntry(vmName: vmName)
           let vm = NavRegistrar.createVm(vmName: vmName, parameters: params)

           entries = [newEntry]
           vmStore[newEntry.id] = vm

           withAnimation(animated ? .easeInOut : nil) {
               path = NavigationPath([newEntry])
           }

           vm.OnNavigatedTo(parameters: params)
           vm.OnAppeared()
    }

    private func multiPushRoot(url: String, params: INavigationParameters, animated: Bool) async throws {
        let clean = url.replacingOccurrences(of: "/NavigationPage", with: "")
        let names = clean.split(separator: "/").map(String.init).filter { !$0.isEmpty }

        // destroy old VMs
        entries.forEach { vmStore[$0.id]?.Destroy() }
        vmStore.removeAll()
        entries.removeAll()
        path = NavigationPath()

        for name in names {
            try await push(vmName: name, params: params, animated: animated)
        }
    }

    private func popToRoot(params: INavigationParameters) async throws {
        guard entries.count > 1 else { return }
        let root = entries.first!

        // destroy others
        entries.dropFirst().forEach { vmStore[$0.id]?.Destroy() }
        vmStore = [:]

        // rebuild root VM freshly to ensure initialized state (or reuse previous if you prefer)
        let vm = NavRegistrar.createVm(vmName: root.vmName, parameters: params)
        entries = [root]
        path = NavigationPath([root])
        vmStore[root.id] = vm

        vm.OnNavigatedTo(parameters: params)
        vm.OnAppeared()
    }

    // MARK: - Rendering helper

    /// Build the view for a PageEntry by injecting the previously created VM as an environment object.
    func viewForEntry(_ entry: PageEntry) -> AnyView {
        guard let vm = vmStore[entry.id] else {
            return AnyView(Text("Missing VM for \(entry.vmName)"))
        }
        // build the zero-arg page and inject the observable wrapper
        let pageView = NavRegistrar.createPageView(vmName: entry.vmName)
        let adapter = PageViewModelObservable(vm: vm)
        return AnyView(pageView.environmentObject(adapter))
    }
}

