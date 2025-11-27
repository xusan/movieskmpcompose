//
//  HomePage.swift
//  iosApp
//
//  Created by xusan on 24/11/25.
//

import SwiftUI

struct HomePage: View {
    @EnvironmentObject var adapter: ViewModelObservable
    var vm: MoviesPageViewModel { adapter.Vm as! MoviesPageViewModel }

    var body: some View {
        VStack(spacing: 20) {
            Text("Home").font(.largeTitle)
            Button("Details") {
                Task {
                    try await SuiPageNavigationService.shared.Navigate(
                        name: "MovieDetailPageViewModel",
                        parameters: NavigationParameters(),
                        useModalNavigation: false,
                        animated: true,
                        wrapIntoNav: false
                    )
                }
            }
            Button("Push Login as Root") {
                Task {
                    try await SuiPageNavigationService.shared.Navigate(
                        name: "/LoginPageViewModel",
                        parameters: NavigationParameters(),
                        useModalNavigation: false,
                        animated: true,
                        wrapIntoNav: false
                    )
                }
            }
        }
    }
}

#Preview {
    HomePage()
}
