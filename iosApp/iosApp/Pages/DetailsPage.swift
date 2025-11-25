//
//  DetailsPage.swift
//  iosApp
//
//  Created by xusan on 24/11/25.
//

import SwiftUI

struct DetailsPage: View {
    @EnvironmentObject var adapter: PageViewModelObservable
    var vm: MovieDetailPageViewModel { adapter.raw as! MovieDetailPageViewModel }

    var body: some View {
        VStack(spacing: 20) {
            Text("Details").font(.largeTitle)
            Button("Back") {
                Task {
                    try await SwiftUIPageNavigationService.shared.Navigate(
                        name: "../",
                        parameters: NavigationParameters(),
                        useModalNavigation: false,
                        animated: true,
                        wrapIntoNav: false
                    )
                }
            }
            
            Button("Push Login as Root") {
                Task {
                        try await SwiftUIPageNavigationService.shared.Navigate(
                            name: "/LoginPageViewModel",
                            parameters: NavigationParameters(),
                            useModalNavigation: false,
                            animated: true,
                            wrapIntoNav: false
                        )
                }
            }
            
            Button("Navigate to Root") {
                Task {
                    try await SwiftUIPageNavigationService.shared.NavigateToRoot(parameters: NavigationParameters())
                }
            }
        }
    }
}

#Preview {
    DetailsPage()
}
