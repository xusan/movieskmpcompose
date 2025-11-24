//
//  LoginPage.swift
//  iosApp
//
//  Created by xusan on 24/11/25.
//

import SwiftUI

struct LoginPage: View {
    @EnvironmentObject var adapter: PageViewModelObservable
    var vm: LoginPageViewModel { adapter.raw as! LoginPageViewModel }

    var body: some View {
        SwiftUIBasePage(viewModel: adapter.raw) {
            VStack(spacing: 20) {
                Text("Login (SwiftUI)")
                    .font(.largeTitle)
                Button("Login -> Home") {
                    Task {
                        try await SwiftUIPageNavigationService.shared.Navigate(
                            name: "MoviesPageViewModel",
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
}

#Preview {
    LoginPage()
}
