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
            try await push(vmName: url, params: params, animated: animated)
        }
        else if nav.isPop {
            try await pop(params: params)
        }
        else if nav.isMultiPop
        {
            try await multiPop(url: url, params: params, animated: animated)
        }
        else if nav.isMultiPopAndPush
        {
            try await multiPopAndPush(url: url, params: params, animated: animated)
        }
        else if nav.isPushAsRoot
        {
            try await pushRoot(url: url, params: params, animated: animated)
        }
        else if nav.isMultiPushAsRoot
        {
            try await multiPushRoot(url: url, params: params, animated: animated)
        }
    }

    // MARK: PUSH

    private func push(vmName: String, params: INavigationParameters, animated: Bool) async throws
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
        
        let entry = PageEntry(vmName: vmName, animated: animated)
        vmStore[entry.id] = vm

        if animated
        {
            withAnimation(.easeInOut) { entries.append(entry) }
            
            try await Task.sleep(for: .seconds(0.3))
        }
        else
        {
            entries.append(entry)
        }
        
        vm.OnAppeared()
    }

    // MARK: POP

    private func pop(params: INavigationParameters) async throws
    {
        guard let oldEntry = entries.last else { return }
        guard entries.count >= 2 else { return }
        let newEntry = entries[entries.count - 2]
       
        let animated = oldEntry.animated
        let oldVm = vmStore[oldEntry.id]
        oldVm?.OnNavigatedFrom(parameters: NavigationParameters())
        vmStore[oldEntry.id] = nil
       
        if let vm = vmStore[newEntry.id] {
            vm.OnNavigatedTo(parameters: params)
        }

        if animated
        {
            _ = withAnimation(.easeInOut)
                {
                    entries.removeLast()
                }
            try await Task.sleep(for: .seconds(0.3))   // 0.3 seconds
        }
        else
        {
            entries.removeLast()
        }

        oldVm?.Destroy()
    }

    private func popToRoot(params: INavigationParameters) async throws
    {
        guard entries.count > 1 else { return }

        if(entries.count == 2)
        {
            try await pop(params: params)
        }
        else
        {
            let root = entries.first!
            if let vm = vmStore[root.id]
            {
                vm.OnNavigatedTo(parameters: params)
                //vm.OnAppeared()
            }
            
            let entriesToRemove = entries.dropFirst()
            
            withAnimation(.easeInOut)
            {
                entries = [root]
            }
            
            try await Task.sleep(for: .seconds(0.3))   // 0.3 seconds
            
            for e in entriesToRemove
            {
                vmStore[e.id]?.Destroy()
                vmStore[e.id] = nil
            }
        }
    }

    // MARK: Multi-pop/push

    private func multiPop(url: String, params: INavigationParameters, animated: Bool) async throws
    {
        // Count how many "../" segments we have
            let count = url.split(separator: "/").count - 1
            guard count > 0 else { return }
            guard entries.count > count else { return }

            // Example:
            // entries = [A, B, C, D, E]
            // count = 3
            // We want to remove C,D silently, then pop E with animation.

            // 1️⃣ Find the new target top index
            let targetIndex = entries.count - 1 - count   // this will be index of "B"

            // 2️⃣ Remove middle pages silently (no animation, no pop())
            //
            // Remove entries from (targetIndex+1) up to (last-1)
            // Keep only the last page (E) to pop with animation
            if count > 1 {
                let removeStart = targetIndex + 1               // C
                let removeEnd = entries.count - 1               // up to E (but we'll keep E)

                let toRemove = entries[removeStart..<removeEnd]

                // Destroy VMs for C, D
                for entry in toRemove {
                    vmStore[entry.id]?.Destroy()
                    vmStore[entry.id] = nil
                }

                // Keep only A, B, and E
                entries = Array(entries[0...targetIndex] + [entries.last!])
            }

            // 3️⃣ Now pop only the actual top (E) with animation
            try await pop(params: params)
    }

    private func multiPopAndPush(url: String, params: INavigationParameters, animated: Bool) async throws
    {
        // 1️⃣ Determine number of ../ segments
        let popCount = url.split(separator: "/").count - 1
        guard popCount > 0 else { return }
        guard popCount < entries.count else { return } // prevent removing root
        
        // 2️⃣ Extract new ViewModel name: "../../E" → "E"
        let newVmName = url.replacingOccurrences(of: "../", with: "")
        
        // 3️⃣ First PUSH new page (animated)
        try await push(vmName: newVmName, params: params, animated: animated)
        
        // 4️⃣ Now silently remove intermediate pages (C, D)
        // Example: entries = [A, B, C, D, E]
        // popCount = 2
        // remove range = (lastIndex - popCount) ..< lastIndex
        let lastIndex = entries.count - 1
        let startRemove = lastIndex - popCount
        let endRemove = lastIndex        // exclude new E
        
        let toRemove = entries[startRemove..<endRemove]
        
        // Keep A, B and E
        let newTop = entries[lastIndex]
        entries = Array(entries.prefix(startRemove) + [newTop])
        
        // Destroy removed VMs
        for entry in toRemove {
            vmStore[entry.id]?.Destroy()
            vmStore[entry.id] = nil
        }
    }

    private func pushRoot(url: String, params: INavigationParameters, animated: Bool) async throws
    {
        let vmName = url
            .replacingOccurrences(of: "/", with: "")
        
        // 1️⃣ Push new page first → this animates
        try await push(vmName: vmName, params: params, animated: animated)
        
        // 2️⃣ Wait for push animation to complete
        if animated {
            try? await Task.sleep(for: .seconds(0.3))
        }
        
        // 3️⃣ Remove all old pages silently (no animation)
        let newRoot = entries.last!
        let oldEntries = entries.dropLast()
        
        let ids = Set(oldEntries.map { $0.id })
        
        // Destroy old VMs
        for id in ids {
            vmStore[id]?.Destroy()
            vmStore[id] = nil
        }
        
        // Keep only the new page
        var transaction = Transaction()
        transaction.disablesAnimations = true
        
        withTransaction(transaction) {
            entries = [newRoot]
        }
    }

    //I think this one is not used, I can't imagine a situation where we would need it.
    private func multiPushRoot(url: String, params: INavigationParameters, animated: Bool) async throws {
//        for e in entries {
//            vmStore[e.id]?.Destroy()
//        }
//        entries = []
//        vmStore = [:]
//
//        let names = url
//            .split(separator: "/")
//            .map(String.init)
//
//        for n in names {
//            try await push(vmName: n, params: params, animated: animated)
//        }
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
