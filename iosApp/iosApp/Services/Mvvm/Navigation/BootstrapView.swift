import SwiftUI


struct BootstrapView: View {
    @EnvironmentObject var nav: iOSNavigationService
    @State private var started = false
    
    var body: some View
    {
        Color.clear.onAppear
            {
                if started { return }
                started = true

                Task
                {
                    //for now just get true
                    let isLogged = true//await AuthService.shared.isLoggedIn()

                    if isLogged
                    {
                        await nav.setRoot(vmName: "FirstViewModel")
                    }
                    else
                    {
                        await nav.setRoot(vmName: "SecondViewModel")
                    }
                }
            }
    }
}
