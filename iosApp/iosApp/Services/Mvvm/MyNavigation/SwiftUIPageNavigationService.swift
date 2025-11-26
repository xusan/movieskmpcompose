import SwiftUI

final class SwiftUIPageNavigationService: NSObject, ObservableObject, IPageNavigationService {
    
    static let shared = SwiftUIPageNavigationService()

    @Published var entries: [PageEntry] = []
    private var vmStore: [UUID: PageViewModel] = [:]

    private override init() {}

    var CanNavigateBack: Bool { entries.count > 1 }

    func GetCurrentPage() -> (any IPage)? { nil }

    func GetCurrentPageModel() -> PageViewModel?
    {
        guard let last = entries.last else { return nil }
        return vmStore[last.id]
    }

    func GetNavStackModels() -> [PageViewModel] {
        entries.compactMap { vmStore[$0.id] }
    }

    func GetRootPageModel() -> PageViewModel? {
        guard let first = entries.first else { return nil }
        return vmStore[first.id]
    }

    func NavigateToRoot(parameters: (any INavigationParameters)?) async throws {
        try await popToRoot(params: parameters ?? NavigationParameters())
    }

    func Navigate(
        name url: String,
        parameters: INavigationParameters?,
        useModalNavigation: Bool,
        animated: Bool,
        wrapIntoNav: Bool
    ) async throws {
        let params = parameters ?? NavigationParameters()
        let nav = UrlNavigationHelper.companion.Parse(url: url)

        if nav.isPush
        {
            try await OnPushAsync(vmName: url, params: params, animated: animated)
        }
        else if nav.isPop
        {
            try await OnPopAsync(params: params)
        }
        else if nav.isMultiPop
        {
            try await OnMultiPopAsync(url: url, params: params, animated: animated)
        }
        else if nav.isMultiPopAndPush
        {
            try await OnMultiPopAndPush(url: url, params: params, animated: animated)
        }
        else if nav.isPushAsRoot
        {
            try await OnPushRootAsync(url: url, params: params, animated: animated)
        }
        else if nav.isMultiPushAsRoot
        {
            try await OnMultiPushRootAsync(url: url, params: params, animated: animated)
        }
    }

    // MARK: PUSH

    private func OnPushAsync(vmName: String, params: INavigationParameters, animated: Bool) async throws
    {
        let info = NavRegistrar.getPageInfo(vmName: vmName)

        if let lastEntry = entries.last
        {
            let vm = vmStore[lastEntry.id]
            vm?.OnNavigatedFrom(parameters: NavigationParameters())
        }
        
        let vm = info.createVm()
        vm.Initialize(parameters: params)
        vm.OnNavigatedTo(parameters: params)
        
        let entry = PageEntry(vmName: vmName)
        vmStore[entry.id] = vm

        entries.append(entry)
        try await Task.sleep(for: .seconds(0.3))
        
        vm.OnAppeared()
    }

    // MARK: POP

    private func OnPopAsync(params: INavigationParameters) async throws
    {
        guard let oldEntry = entries.last else { return }
        guard entries.count >= 2 else { return }
        let newEntry = entries[entries.count - 2]
               
        let oldVm = vmStore[oldEntry.id]
        oldVm?.OnNavigatedFrom(parameters: NavigationParameters())
        vmStore[oldEntry.id] = nil
       
        if let vm = vmStore[newEntry.id]
        {
            vm.OnNavigatedTo(parameters: params)
        }

        entries.removeLast()
        
        try await Task.sleep(for: .seconds(0.3))

        oldVm?.Destroy()
    }

    private func popToRoot(params: INavigationParameters) async throws
    {
        guard entries.count > 1 else { return }

        if(entries.count == 2)
        {
            try await OnPopAsync(params: params)
        }
        else
        {
            // OnNavigatedFrom only for the current top (before changes)
            if let oldTop = entries.last, let oldVm = vmStore[oldTop.id]
            {
                oldVm.OnNavigatedFrom(parameters: NavigationParameters())
            }
            let root = entries.first!
            if let vm = vmStore[root.id]
            {
                vm.OnNavigatedTo(parameters: params)
                //vm.OnAppeared()
            }
            
            let entriesToRemove = entries.dropFirst()
            
            entries = [root]
            
            try await Task.sleep(for: .seconds(0.3))   // 0.3 seconds
            
            for e in entriesToRemove
            {
                vmStore[e.id]?.Destroy()
                vmStore[e.id] = nil
            }
        }
    }

    // MARK: Multi-pop/push

    private func OnMultiPopAsync(url: String, params: INavigationParameters, animated: Bool) async throws
    {
        let popCount = url.split(separator: "/").count
        guard popCount > 0 else { return }
        guard popCount < entries.count else { return } // keep root
        
        // Determine final count to keep
        let newCount = entries.count - popCount
        // entries to remove
        let removedEntries = entries[newCount...]
        
        // OnNavigatedFrom only for the current top (before changes)
        if let oldTop = entries.last, let oldVm = vmStore[oldTop.id]
        {
            oldVm.OnNavigatedFrom(parameters: NavigationParameters())
        }
        
        // Assign final array once: SwiftUI performs single pop animation
        entries = Array(entries.prefix(newCount))
        
        try? await Task.sleep(for: .seconds(0.30))
        
        // Destroy all removed VMs
        for entry in removedEntries
        {
            if let vm = vmStore[entry.id]
            {
                vm.Destroy()
                vmStore[entry.id] = nil
            }
        }
    }

    private func OnMultiPopAndPush(url: String, params: INavigationParameters, animated: Bool) async throws
    {
        let popCount = url.split(separator: "/").count - 1
        guard popCount > 0 else { return }
        guard popCount < entries.count else { return }
        
        // new VM name is the url with ../ removed
        let newVmName = url.replacingOccurrences(of: "../", with: "")
        
        // create new vm & entry inline
        let info = NavRegistrar.getPageInfo(vmName: newVmName)
        let vm = info.createVm()
        vm.Initialize(parameters: params)
        
        let newEntry = PageEntry(vmName: newVmName)
        vmStore[newEntry.id] = vm
        
        // OnNavigatedFrom only for previous top
        if let oldTop = entries.last, let oldVm = vmStore[oldTop.id]
        {
            oldVm.OnNavigatedFrom(parameters: NavigationParameters())
        }
        vm.OnNavigatedTo(parameters: params)
        
        // compute new stack keeping prefix and adding newEntry
        let newCount = entries.count - popCount
        let removedEntries = entries[newCount...]
        
        // final array assigned once -> SwiftUI animates a single push
        entries = Array(entries.prefix(newCount)) + [newEntry]
        try? await Task.sleep(for: .seconds(0.30))
        
        // Destroy removed VMs
        for entry in removedEntries
        {
            if let vm = vmStore[entry.id]
            {
                vm.Destroy()
                vmStore[entry.id] = nil
            }
        }
    }

    private func OnPushRootAsync(url: String, params: INavigationParameters, animated: Bool) async throws
    {
        let vmName = url
            .replacingOccurrences(of: "/", with: "")
        
        var newRoot: PageEntry
        let oldEntries = entries
        
        //if has existing pages
        if entries.count > 0
        {
            //Push new page first → this animates
            try await OnPushAsync(vmName: vmName, params: params, animated: animated)
            
            //get this new pushed page, it will be new root
            newRoot = entries.last!
        }
        else
        {
            //if there is no other pages then just create this root and it will be pushed without animation below
            let info = NavRegistrar.getPageInfo(vmName: vmName)
            let vm = info.createVm()
            vm.Initialize(parameters: params)
            vm.OnNavigatedTo(parameters: params)
            vm.OnAppeared()
            
            newRoot = PageEntry(vmName: vmName)
            vmStore[newRoot.id] = vm
        }
        
        // Keep only the new page,
        //we disable animation as array is reducing and it will cause pop animation
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction)
        {
            entries = [newRoot]
        }
       
        // Destroy removed VMs
        for entry in oldEntries
        {
            if let vm = vmStore[entry.id]
            {
                vm.Destroy()
                vmStore[entry.id] = nil
            }
        }
    }

    //I think this one is not used, I can't imagine a situation where we would need it.
    private func OnMultiPushRootAsync(url: String, params: INavigationParameters, animated: Bool) async throws
    {
        let names = url
            .split(separator: "/")
            .map(String.init)
            .filter { !$0.isEmpty }
        
        guard !names.isEmpty else { return }
        
        // OnNavigatedFrom for previous item in this push sequence (if any)
        if let prev = entries.last, let prevVm = vmStore[prev.id]
        {
            prevVm.OnNavigatedFrom(parameters: NavigationParameters())
        }
        
        var newEntries: [PageEntry] = []
        
        // Push sequence into local array (so we don't touch the global entries until final)
        for name in names
        {
            let info = NavRegistrar.getPageInfo(vmName: name)
            let vm = info.createVm()
            vm.Initialize(parameters: params)
            
            let entry = PageEntry(vmName: name)
            vmStore[entry.id] = vm
            
            newEntries.append(entry)
            
            // Notify newly pushed vm
            vm.OnNavigatedTo(parameters: params)
        }
        
        // final array assigned once -> SwiftUI animates a single push
        let oldEntries = entries
        entries = newEntries
        try? await Task.sleep(for: .seconds(0.30))
        
        // Destroy all old VMs
        for entry in oldEntries
        {
            if let oldVm = vmStore[entry.id]
            {
                oldVm.Destroy()
                vmStore[entry.id] = nil
            }
        }
    }

    // MARK: BUILD VIEW
    func viewForEntry(_ entry: PageEntry) -> AnyView
    {
        let info = NavRegistrar.getPageInfo(vmName: entry.vmName)
        let vm = vmStore[entry.id]!
        let obs = PageViewModelObservable(vm: vm)
        
        let page = info.createPage()
            .environmentObject(obs)
        
        // Wrap page with overlay
        let wrapped = PageOverlay(content: page)
        
        return AnyView(wrapped)
    }
}
