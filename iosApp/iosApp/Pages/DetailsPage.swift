//
//  DetailsPage.swift
//  iosApp
//
//  Created by xusan on 24/11/25.
//

import SwiftUI

struct DetailsPage: View {
    @EnvironmentObject var adapter: ViewModelObservable
    var vm: MovieDetailPageViewModel { adapter.Vm as! MovieDetailPageViewModel }

    var body: some View {
        VStack(spacing: 20) {
            Text("Details").font(.largeTitle)
//            Button("Back") {
//                Task {
//                    try await SwiftUIPageNavigationService.shared.Navigate(
//                        name: "../",
//                        parameters: NavigationParameters(),
//                        useModalNavigation: false,
//                        animated: true,
//                        wrapIntoNav: false
//                    )
//                }
//            }
            
            Button("Login as Root")
            {
                Task
                {
                    try await SwiftUIPageNavigationService.shared.Navigate(
                        name: "/LoginPageViewModel",
                        parameters: NavigationParameters(),
                        useModalNavigation: false,
                        animated: true,
                        wrapIntoNav: false
                    )
                }
            }
            
            Button("Navigate to Root")
            {
                Task
                {
                    try await SwiftUIPageNavigationService.shared.NavigateToRoot(parameters: NavigationParameters())
                }
            }
            
            Button("Pop multi ../../")
            {
                Task
                {
                    try await SwiftUIPageNavigationService.shared.Navigate(
                        name: "../../",
                        parameters: NavigationParameters(),
                        useModalNavigation: false,
                        animated: true,
                        wrapIntoNav: false
                    )
                }
            }
            
            Button("Pop multi and Push ../../AddEditPage")
            {
                Task
                {
                    try await SwiftUIPageNavigationService.shared.Navigate(
                        name: "../../AddEditMoviePageViewModel",
                        parameters: NavigationParameters(),
                        useModalNavigation: false,
                        animated: true,
                        wrapIntoNav: false)
                }
            }
            
            
        }
    }
}

#Preview {
    DetailsPage()
}
