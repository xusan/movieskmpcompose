import SwiftUI
import SharedAppCore

@main struct iOSApp: App
{
    init()
    {
        let appErrorTracking = iOSErrorTrackingService()
        let navigationService = Sui_PageNavigationService.shared
        let bootstrap = Bootstrap()
        bootstrap.RegisterTypes(navigationService, appErrorTracking)
        bootstrap.NavigateToPage(navigationService)
    }
    
    var body: some Scene
    {
        WindowGroup
        {
            RootView()           
        }
    }
}
