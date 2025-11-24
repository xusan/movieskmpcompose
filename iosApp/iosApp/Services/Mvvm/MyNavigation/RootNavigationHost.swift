import SwiftUI

struct RootNavigationHost: View {
    @StateObject private var nav = SwiftUIPageNavigationService.shared

    var body: some View {
        NavigationStack(path: $nav.path) {
            Group {
                if let first = nav.entries.first {
                    nav.viewForEntry(first)
                } else {
                    Text("No root page")
                }
            }
            .navigationDestination(for: PageEntry.self) { entry in
                nav.viewForEntry(entry)
            }
        }
    }
}
