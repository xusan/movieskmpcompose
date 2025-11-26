import SwiftUI
import SharedAppCore

@main struct iOSApp: App
{
    init()
    {
        let appErrorTracking = iOSErrorTrackingService()
        let navigationService = SwiftUIPageNavigationService.shared
        let bootstrap = Bootstrap()
        bootstrap.RegisterTypes(navigationService, appErrorTracking)
        bootstrap.NavigateToPage(navigationService)
    }
    
    var body: some Scene
    {
        WindowGroup
        {
            RootNavigationHost()           
        }
    }
}
