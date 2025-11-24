import SwiftUI

@main struct iOSApp: App
{
    
    
    var body: some Scene
    {
        
        ////we need to make below code run only once not sure how much body property will be called
//        let bootstrap = Bootstrap()
//        bootstrap.RegisterTypes(self.pageNavigationService, errorTrackingService)
//        
//        let loggingService = try! KoinResolver().GetLoggingService()
//        loggingService.Log(message: "####################################################- APPLICATION STARTED -####################################################")
//        loggingService.Log(message: "AppDelegate.FinishedLaunching()")
//               
//       Task {
//           await bootstrap.NavigateToPage(pageNavigationService)
//           //setup attachment for error tracking service.
//           // NOTE: The log file is only created after the first log entry.
//           // A small delay is required to allow the buffer to flush to disk.
//           try? await Task.sleep(nanoseconds: 300 * 1_000_000)
//           appDelegate.appErrorTracking.SetupAttachment()
//       }
        
        WindowGroup
        {
            ContentView()
        }
    }
}
