import SwiftUI

final class Sui_PageNavigationService: NSObject, ObservableObject, IPageNavigationService
{
    private override init() {}
    
    @Published var Stack: [PageItem] = []

    //MARK: - IPageNavigationService implementation
    
    var CanNavigateBack: Bool { Stack.count > 1 }

    func GetCurrentPage() -> (any IPage)? { nil }

    func GetCurrentPageModel() -> PageViewModel?
    {
        guard let last = Stack.last else { return nil }
        return last.VmObs.Vm
    }

    func GetNavStackModels() -> [PageViewModel]
    {
        Stack.compactMap { $0.VmObs.Vm }
    }

    func GetRootPageModel() -> PageViewModel?
    {
        guard let first = Stack.first else { return nil }
        return first.VmObs.Vm
    }
    
    //This is a Sync version of navigation, and used mostly on app startup to set root page
    //Sync version is more prefered at app startup
    //because Async version takes some delay to navigate due to async nature and user can see black root view if Async version is used    
    func OnNavigateFirstTime(_ url: String, _ params: INavigationParameters)
    {
        let vmName = url.replacingOccurrences(of: "/", with: "")
        let info = NavRegistrar.GetPageInfo(vmName: vmName)
        let vm = info.createVm()
        vm.Initialize(parameters: params)
        vm.OnNavigatedTo(parameters: params)
        vm.OnAppeared()
        
        let vmObs = ViewModelObservable(vm: vm)
        let newRoot = PageItem(vmName, vmObs)
        Stack = [newRoot]
    }

    @MainActor
    func NavigateToRoot(parameters: (any INavigationParameters)?) async throws
    {
        try await OnPopToRootAsync(params: parameters ?? NavigationParameters())
    }

    @MainActor
    func Navigate(
        name url: String,
        parameters: INavigationParameters?,
        useModalNavigation: Bool,
        animated: Bool,
        wrapIntoNav: Bool
    ) async throws
    {
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

    //MARK: - Helper methods

    private func OnPushAsync(vmName: String, params: INavigationParameters, animated: Bool) async throws
    {
        let info = NavRegistrar.GetPageInfo(vmName: vmName)

        if let oldTopItem = Stack.last
        {
            oldTopItem.VmObs.Vm!.OnNavigatedFrom(parameters: NavigationParameters())
        }
        
        let vm = info.createVm()
        let vmObs = ViewModelObservable(vm: vm)
        let newItem = PageItem(vmName, vmObs)
        vm.Initialize(parameters: params)
        vm.OnNavigatedTo(parameters: params)

        Stack.append(newItem)
        try await Task.sleep(for: .seconds(0.3))
        
        vm.OnAppeared()
    }

    // MARK: POP

    private func OnPopAsync(params: INavigationParameters) async throws
    {
        guard let oldTopItem = Stack.last else { return }
        guard Stack.count >= 2 else { return }
        
        oldTopItem.VmObs.Vm!.OnNavigatedFrom(parameters: NavigationParameters())
       
        let newTopItem = Stack[Stack.count - 2]
        newTopItem.VmObs.Vm!.OnNavigatedTo(parameters: params)

        Stack.removeLast()
        
        try await Task.sleep(for: .seconds(0.3))
        
        oldTopItem.VmObs.Destroy()
    }

    private func OnPopToRootAsync(params: INavigationParameters) async throws
    {
        guard Stack.count > 1 else { return }

        if(Stack.count == 2)
        {
            try await OnPopAsync(params: params)
        }
        else
        {
            // OnNavigatedFrom only for the current top (before changes)
            if let oldTopItem = Stack.last
            {
                oldTopItem.VmObs.Vm!.OnNavigatedFrom(parameters: NavigationParameters())
            }
            
            let root = Stack.first!
            root.VmObs.Vm!.OnNavigatedTo(parameters: params)
            
            let removedItems = Stack.dropFirst()
            
            Stack = [root]
            
            try await Task.sleep(for: .seconds(0.3))   // 0.3 seconds
            
            // Destroy all removed VMs
            for removedItem in removedItems
            {
                removedItem.VmObs.Destroy()
            }
        }
    }

    // MARK: Multi-pop/push

    private func OnMultiPopAsync(url: String, params: INavigationParameters, animated: Bool) async throws
    {
        let popCount = url.split(separator: "/").count
        guard popCount > 0 else { return }
        guard popCount < Stack.count else { return } // keep root
                
        // OnNavigatedFrom only for the current top (before changes)
        if let oldTopItem = Stack.last
        {
            oldTopItem.VmObs.Vm!.OnNavigatedFrom(parameters: NavigationParameters())
        }
        
        // Determine final count to keep
        let newCount = Stack.count - popCount
        // entries to remove
        let removedItems = Stack[newCount...]
        
        // Assign final array once: SwiftUI performs single pop animation
        Stack = Array(Stack.prefix(newCount))
        
        try? await Task.sleep(for: .seconds(0.30))
        
        // Destroy all removed VMs
        for removedItem in removedItems
        {
            removedItem.VmObs.Destroy()
        }
    }

    private func OnMultiPopAndPush(url: String, params: INavigationParameters, animated: Bool) async throws
    {
        let popCount = url.split(separator: "/").count - 1
        guard popCount > 0 else { return }
        guard popCount < Stack.count else { return }
        
        // new VM name is the url with ../ removed
        let newVmName = url.replacingOccurrences(of: "../", with: "")
        
        // create new vm & entry inline
        let info = NavRegistrar.GetPageInfo(vmName: newVmName)
        let vm = info.createVm()
        let vmObs = ViewModelObservable(vm: vm)
        let newItem = PageItem(newVmName, vmObs)
        vm.Initialize(parameters: params)
        
        // OnNavigatedFrom only for previous top
        if let oldTop = Stack.last
        {
            oldTop.VmObs.Vm!.OnNavigatedFrom(parameters: NavigationParameters())
        }
        newItem.VmObs.Vm!.OnNavigatedTo(parameters: params)
        
        // compute new stack keeping prefix and adding newEntry
        let newCount = Stack.count - popCount
        let removedItems = Stack[newCount...]
        
        // final array assigned once -> SwiftUI animates a single push
        Stack = Array(Stack.prefix(newCount)) + [newItem]
        try? await Task.sleep(for: .seconds(0.30))
                
        // Destroy all removed VMs
        for removedItem in removedItems
        {
            removedItem.VmObs.Destroy()
        }
    }

    private func OnPushRootAsync(url: String, params: INavigationParameters, animated: Bool) async throws
    {
        let vmName = url
            .replacingOccurrences(of: "/", with: "")
        
        var newRoot: PageItem
        let removedItems = Stack
        
        //if has existing pages
        if Stack.count > 0
        {
            //Push new page first → this animates
            try await OnPushAsync(vmName: vmName, params: params, animated: animated)
            
            //get this new pushed page, it will be new root
            newRoot = Stack.last!
        }
        else
        {
            //if there is no other pages then just create this root and it will be pushed without animation below
            let info = NavRegistrar.GetPageInfo(vmName: vmName)
            let vm = info.createVm()
            let vmObs = ViewModelObservable(vm: vm)
            newRoot = PageItem(vmName, vmObs)
            vm.Initialize(parameters: params)
            vm.OnNavigatedTo(parameters: params)
            vm.OnAppeared()
        }
        
        // Keep only the new page,
        //we disable animation as array is reducing and it will cause pop animation
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction)
        {
            Stack = [newRoot]
        }
       
        // Destroy all removed VMs
        for removedItem in removedItems
        {
            removedItem.VmObs.Destroy()
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
        if let oldTopItem = Stack.last
        {
            oldTopItem.VmObs.Vm!.OnNavigatedFrom(parameters: NavigationParameters())
        }
        
        var newItems: [PageItem] = []
        
        // Push sequence into local array (so we don't touch the global entries until final)
        for name in names
        {
            let info = NavRegistrar.GetPageInfo(vmName: name)
            let vm = info.createVm()
            let vmObs = ViewModelObservable(vm: vm)
            let item = PageItem(name, vmObs)
            vm.Initialize(parameters: params)
            vm.OnNavigatedTo(parameters: params)
            
            newItems.append(item)
        }
        
        // final array assigned once -> SwiftUI animates a single push
        let removedItems = Stack
        Stack = newItems
        try? await Task.sleep(for: .seconds(0.30))
        
        // Destroy all removed VMs
        for removedItem in removedItems
        {
            removedItem.VmObs.Destroy()
        }
    }

    // MARK: BUILD VIEW
    func GetViewForItem(_ item: PageItem) -> AnyView
    {
        let info = NavRegistrar.GetPageInfo(vmName: item.VmName)
        let pageItem = Stack.first{ $0.VmName == item.VmName } //ViewModelObservable(vm: item.Vm)
        let vmObs = pageItem!.VmObs
        let page = info.createPage()
            .environmentObject(vmObs)
        
        if let mainVm = vmObs.Vm as? MoviesPageViewModel
        {
            print("MovieItems.Count = \(mainVm.MovieItems.Count())")
        }
        
        return AnyView(page)
    }
    
    static let shared = Sui_PageNavigationService()
}
