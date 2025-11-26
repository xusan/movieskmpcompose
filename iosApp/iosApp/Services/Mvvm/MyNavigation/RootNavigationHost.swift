import SwiftUI

struct RootNavigationHost: View
{
    @StateObject private var nav = SwiftUIPageNavigationService.shared

    var body: some View {
        NavigationStack(path: $nav.entries) {
            Color.clear //root is just empty view. entries[0] page will be root
                .navigationDestination(for: PageEntry.self) { entry in
                    nav.viewForEntry(entry)
                        //.navigationBarBackButtonHidden(true) //hide navigation bar for all
                        .gesture(                            // swallow gesture for entries[0] page
                            entry.id == nav.entries.first?.id
                                ? DragGesture()
                                : nil
                        )
                }
        }
    }
}

