import SwiftUI
import Combine
import Foundation

@MainActor
final class iOSNavigationService: IPageNavigationService, ObservableObject
{
    @Published public var path = NavigationPath()

    // INTERNAL stack we control
    public var routes: [Route] = []
    public var currentRoute: Route? { routes.last }
    //private let registrar: iOSNavRegistrar
    
    
    public init()
    {
        
    }

    
    public var CanNavigateBack: Bool
    {
        get { return routes.count > 1 }
    }
    // Exposed helpers similar to your UIKit API
    public func GetCurrentPageModel() -> PageViewModel?
    {
        return routes.last?.vm
    }

    public func GetNavStackModels() -> [PageViewModel]
    {
        return routes.map { $0.vm }
    }

    public func GetRootPageModel() -> PageViewModel?
    {
        return routes.first?.vm
    }
    
    public func GetCurrentPage() -> (any IPage)?
    {
        return (currentRoute?.view as? IBaseView)?.GetPage()
    }
    
    func NavigateToRoot(parameters: (any INavigationParameters)?) async throws
    {
        if(parameters != nil)
        {
            try await OnPopToRootAsync(parameters!)
        }
        else
        {
            try await OnPopToRootAsync(NavigationParameters())
        }
    }
   
    private func syncPath()
    {
        if routes.count <= 1
        {
            // Only one route = root page = NO back button
            path = NavigationPath()
        }
        else
        {
            // Tail = everything except root
            let tail = Array(routes.dropFirst())
            path = NavigationPath(tail)
        }

        print("SYNC → routes=\(routes.count), path=\(path.count)")
    }
   
    
    func setRoot(vmName: String, parameters: INavigationParameters = NavigationParameters()) async
    {
        
        let (view, vm) = iOSNavRegistrar.CreateView(vmName: vmName, parameters: parameters)
        vm.OnNavigatedTo(parameters: parameters)

        // Replace entire stack
        routes = [Route(vmName: vmName, view: view, vm: vm)]

        // Root must NOT be in path
        path = NavigationPath()

        print("setRoot → root=\(vmName)")
    }
    
    
    public func syncRoutesWithPath(_ newPath: NavigationPath)
    {

        let expectedRoutesCount = 1 + newPath.count
        let currentRoutesCount = routes.count

        if expectedRoutesCount == currentRoutesCount {
            // No change (push or pop already handled)
            return
        }

        if expectedRoutesCount < currentRoutesCount {
            // User popped pages using back button or swipe
            let diff = currentRoutesCount - expectedRoutesCount
            
            for _ in 0..<diff {
                if routes.count > 1 { // never remove root
                    let removed = routes.removeLast()
                    removed.vm.OnNavigatedFrom(parameters: NavigationParameters())
                    removed.vm.OnDisappearing()
                }
            }
            
            routes.last?.vm.OnNavigatedTo(parameters: NavigationParameters())
        }

        // Pushes by UI (not by service) are extremely rare, ignore them.

        syncPath()
    }

    /// Navigate from URL-like string (uses UrlNavigationHelper - adapt if necessary)
    public func Navigate(
        name url: String,
        parameters: INavigationParameters? = nil,
        useModalNavigation: Bool = false,
        animated: Bool = true,
        wrapIntoNav: Bool = false
    ) async throws
    {
        let parameters = parameters ?? NavigationParameters()
        // For demonstration, assume it's a push. Replace with actual parsing logic.
        let navInfo = UrlNavigationHelper.companion.Parse(url: url)

        if navInfo.isPush
        {
            print("iOSNavigationService: Navigating to \(url) with Push")
            try await OnPushAsync(url, parameters: parameters, animated: animated)
        }
        else if navInfo.isPop
        {
            print("iOSNavigationService: Navigating to \(url) with Pop")
            try await OnPopAsync(parameters: parameters)
        }
        else if navInfo.isMultiPop
        {
            try await OnMultiPopAsync(url: url, parameters: parameters, animated: animated)
        }
        else if navInfo.isMultiPopAndPush
        {
            try await OnMultiPopAndPush(url, parameters: parameters, animated: animated)
        }
        else if navInfo.isPushAsRoot
        {
            try await OnPushRootAsync(url, parameters: parameters, animated: animated)
        }
        else if navInfo.isMultiPushAsRoot
        {
            try await OnMultiPushRootAsync(url, parameters: parameters, animated: animated)
        }
        else
        {
            throw NSError(domain: "Navigation", code: -1, userInfo: [NSLocalizedDescriptionKey: "Navigation case is not implemented."])
        }
    }

    // MARK: - Push
    private func OnPushAsync(_ vmName: String, parameters: INavigationParameters, animated: Bool) async throws
    {
        // Create view and VM (Initialize already called in registrar.CreateView)
        let (view, vm) = iOSNavRegistrar.CreateView(vmName: vmName, parameters: parameters)
        
            
        // Call OnNavigatedFrom on previous
        if let last = routes.last
        {
            last.vm.OnNavigatedFrom(parameters: NavigationParameters())
        }

        // Call OnNavigatedTo on new
        vm.OnNavigatedTo(parameters: parameters)

        // Append to our stack
        let route = Route(vmName: vmName, view: view, vm: vm)
        routes.append(route)
        syncPath()
    }

    // MARK: - Pop
    private func OnPopAsync(parameters: INavigationParameters) async throws
    {
        guard let oldTop = routes.last else { return }

        // Call OnNavigatedFrom for current (mimic original passing empty params)
        oldTop.vm.OnNavigatedFrom(parameters: NavigationParameters())

        // Remove it
        routes.removeLast()
        syncPath()

        // Call OnNavigatedTo on new top
        if let newTop = routes.last
        {
            newTop.vm.OnNavigatedTo(parameters: parameters)
        }

        // Optionally call Destroy on oldTop.vm if you implement it
        oldTop.vm.Destroy()
    }

    // MARK: - Multi Pop
    private func OnMultiPopAsync(url: String, parameters: INavigationParameters, animated: Bool) async throws
    {
        let splitCount = url.split(separator: "/").count - 1
        guard splitCount > 0 else { return }

        var removed: [Route] = []
        for _ in 0..<splitCount
        {
            if let last = routes.last
            {
                last.vm.OnNavigatedFrom(parameters: NavigationParameters())
                removed.append(last)
                routes.removeLast()
            }
        }

        // Call OnNavigatedTo for new top
        if let newTop = routes.last
        {
            newTop.vm.OnNavigatedTo(parameters: parameters)
        }

        syncPath()

        // Clean up removed VMs if needed (call Destroy)
        for r in removed
        {
            r.vm.Destroy()
        }
    }

    // MARK: - Multi Pop and Push
    private func OnMultiPopAndPush(_ url: String, parameters: INavigationParameters, animated: Bool) async throws
    {
        // format: "../../TargetVM"
        let parts = url.split(separator: "/").map { String($0) }
        let popCount = parts.filter { $0 == ".." }.count
        let target = parts.filter { $0 != ".." && !$0.isEmpty }.last
        guard let vmName = target else { return }

        // pop N
        var removed: [Route] = []
        for _ in 0..<popCount
        {
            if let last = routes.last
            {
                last.vm.OnNavigatedFrom(parameters: NavigationParameters())
                removed.append(last)
                routes.removeLast()
            }
        }

        // create and push new
        let (view, vm) = iOSNavRegistrar.CreateView(vmName: vmName, parameters: parameters)
        vm.OnNavigatedTo(parameters: parameters)
        let route = Route(vmName: vmName, view: view, vm: vm)
        routes.append(route)
        syncPath()

        // cleanup
        for r in removed
        {
           r.vm.Destroy()
        }
    }

    // MARK: - Push Root
    private func OnPushRootAsync(_ url: String, parameters: INavigationParameters, animated: Bool) async throws
    {
        var vmName = url.replacingOccurrences(of: "/", with: "")
        vmName = vmName.replacingOccurrences(of: "NavigationPage", with: "")
        
        // 1. Create new root page
        let (view, vm) = iOSNavRegistrar.CreateView(vmName: vmName, parameters: parameters)
        vm.OnNavigatedTo(parameters:parameters)
        
        // 2. Store old pages for cleanup
        let oldRoutes = routes
        
        // 3. Replace entire stack with the new root
        routes = [Route(vmName: vmName, view: view, vm: vm)]
        syncPath()
        
        // 4. Call Destroy on old VMs
        for route in oldRoutes
        {
            if route.vmName != vmName  // avoid destroying new root
            {
                route.vm.Destroy()
            }
        }
    }

    // MARK: - Multi Push Root
    private func OnMultiPushRootAsync(_ url: String, parameters: INavigationParameters, animated: Bool) async throws
    {
        let cleanUrl = url.replacingOccurrences(of: "/NavigationPage", with: "")
        let vmPages = cleanUrl.split(separator: "/").map { String($0) }.filter { !$0.isEmpty }

        var newRoutes: [Route] = []
        for vmName in vmPages
        {
            let (view, vm) = iOSNavRegistrar.CreateView(vmName: vmName, parameters: parameters)
            vm.OnNavigatedTo(parameters: parameters)
            newRoutes.append(Route(vmName: vmName, view: view, vm: vm))
        }

        routes = newRoutes
        syncPath()
    }

    // MARK: - Pop To Root
    private func OnPopToRootAsync(_ parameters: INavigationParameters) async throws
    {
        guard routes.count > 1 else { return }
        
        // 1. Store all pages except root for cleanup
        let oldRoutes = Array(routes.dropFirst())
        
        // 2. Call navigated-from on the top page before removing
        routes.last?.vm.OnNavigatedFrom(parameters: NavigationParameters())
        
        // 3. Keep root only
        let root = routes.first!
        routes = [root]
        syncPath()
        
        // 4. Call navigated-to on new top (root)
        root.vm.OnNavigatedTo(parameters: parameters)
        
        // 5. Cleanup all removed pages
        for route in oldRoutes
        {
            route.vm.Destroy()
        }
    }
   
}




/// Element stored in NavigationPath
//@MainActor
public struct Route: Hashable, Identifiable
{
    public let id: UUID
    public let vmName: String
    public let view: AnyView
    public let vm: PageViewModel

    public init(vmName: String, view: AnyView, vm: PageViewModel)
    {
        self.id = UUID()
        self.vmName = vmName
        self.view = view
        self.vm = vm
    }

    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }

    public static func == (lhs: Route, rhs: Route) -> Bool
    {
        lhs.id == rhs.id
    }
}
