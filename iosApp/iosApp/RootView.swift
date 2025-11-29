import SwiftUI
import SharedAppCore

struct RootView: View
{
    @StateObject private var nav = Sui_PageNavigationService.shared
    @StateObject private var snackbarManager = SnackbarManager.shared
    @StateObject private var busyIndicatorManager = BusyIndicatorManager.shared
    
    var body: some View
    {
        ZStack
        {
            // Layer 1 — Navigation content
            NavigationStack(path: $nav.Stack)
            {
                // Apple’s design expects a statically defined root view, where Stack[0] is the second PageView.
                // We don’t follow this pattern — instead, we treat Stack[0] as our dynamic root view.
                Color.black // The true static root is just a placeholder black view. Our real root view comes from Stack[0].
                    .navigationDestination(for: PageItem.self)
                    { item in
                        
                        let isRoot = item.id == nav.Stack.first?.id
                        
                        nav.GetViewForItem(item)
                            .background(Color(ColorConstants.BgColor.ToUIColor()))
                            .navigationBarBackButtonHidden(isRoot) //hide navigation bar for root page, as our root is still second page and iOS will show back button for it
                    }
            }
            .hideKeyboardOnTap() //hide keyboard when tap anywhere on page
            .alertIfNeeded() //show alert if IAlertDialogService requires
            .confirmationDialogIfNeeded() //show actionSheet if IAlertDialogService requires
            
            // Layer 2 — Snackbar overlay
            if snackbarManager.isShowing
            {
                Sui_SnackbarView()
            }
            
            // Layer 2 — BusyIndicator overlay
            if busyIndicatorManager.isShowing
            {
                Sui_BusyIndicatorView()
            }
        }
    }
}

