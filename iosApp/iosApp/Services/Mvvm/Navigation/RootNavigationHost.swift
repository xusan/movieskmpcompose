import SwiftUI
import SharedAppCore

struct RootNavigationHost: View
{
    @StateObject private var nav = SwiftUIPageNavigationService.shared

    var body: some View {
        NavigationStack(path: $nav.Stack)
        {
            // Apple’s design expects a statically defined root view, where Stack[0] is the second PageView.
            // We don’t follow this pattern — instead, we treat Stack[0] as our dynamic root view.
            Color.black // The true static root is just a placeholder black view. Our real root view comes from Stack[0].
                .navigationDestination(for: PageItem.self) { item in
                    let isRoot = item.id == nav.Stack.first?.id
                    
                    nav.GetViewForItem(item)
                         .navigationBarBackButtonHidden(isRoot) //hide navigation bar for root page, as our root is still second page and iOS will show back button for it
                }
        }
    }
}

