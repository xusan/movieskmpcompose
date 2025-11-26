import SwiftUI
import SharedAppCore

@main struct iOSApp: App
{
    //@StateObject
    private var nav = iOSNavigationService()
    private let appErrorTracking = iOSErrorTrackingService()
    init() {
        let appErrorTracking = iOSErrorTrackingService()
        let navigationService = SwiftUIPageNavigationService.shared
        let bootstrap = Bootstrap()
        bootstrap.RegisterTypes(nav, appErrorTracking)
        
        // Set initial root
        Task
        {
            await bootstrap.NavigateToPage(navigationService)
        }
    }
    
    var body: some Scene
    {
        WindowGroup
        {
            RootNavigationHost()
//            RootView()
//                .environmentObject(nav)
//                .onAppear
//                {
//                   
//                }
        }
    }
}
