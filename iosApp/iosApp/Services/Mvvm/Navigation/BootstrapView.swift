import SwiftUI
import SharedAppCore

struct BootstrapView: View {
    //@EnvironmentObject var nav: iOSNavigationService
    @State private var started = false
    
    var body: some View
    {
        Color.clear.onAppear
            {
                if started { return }
                started = true

                Task
                {
                    let navService = try! KoinResolver().GetNavigationService()
                    let preferences = try! KoinResolver().GetPreferences()
                    let isLoggedIn = preferences.Get(LoginPageViewModel.companion.IsLoggedIn, default: false)
                    
                    let nav = navService as! iOSNavigationService                    

                    if isLoggedIn
                    {
                        await nav.setRoot(vmName: "SecondViewModel")
                    }
                    else
                    {
                        await nav.setRoot(vmName: "FirstViewModel")
                    }
                }
            }
    }
}
