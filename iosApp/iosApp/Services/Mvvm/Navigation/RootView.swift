import SwiftUI

struct RootView: View
{
    @EnvironmentObject var nav: iOSNavigationService

    var body: some View
    {
        NavigationStack(path: $nav.path)
        {
            /// Root page = routes.first?.view
            if let root = nav.routes.first
            {
                root.view
                    .navigationDestination(for: Route.self) { route in
                        route.view
                    }
            }
            else
            {
                /// Show Bootstrap only if no routes are set
                BootstrapView()
            }
        }
        .onChange(of: nav.path)
        { newPath in
           
            nav.syncRoutesWithPath(newPath)
        }
    }
}
