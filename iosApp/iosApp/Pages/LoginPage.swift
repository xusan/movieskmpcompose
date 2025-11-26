//
//  LoginPage.swift
//  iosApp
//
//  Created by xusan on 24/11/25.
//
import SwiftUI


struct LoginPage: View {

    @EnvironmentObject var vmObs: ViewModelObservable
    private var Vm: LoginPageViewModel
    {
        get
        {
            vmObs.Vm as! LoginPageViewModel
        }
    }

    @State private var username = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Login").font(.largeTitle.bold())

            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

//            Button("Login") {
//                Vm.Login = username
//                Vm.Password = password
//                Vm.SubmitCommand.Execute()
//            }
//            .frame(maxWidth: .infinity)
//            .padding()
//            .background(.blue)
//            .foregroundColor(.white)
//            .cornerRadius(12)
            
            Button("Main as Root") {
                Task {
                    try await SwiftUIPageNavigationService.shared.Navigate(
                        name: "/MoviesPageViewModel",
                        parameters: NavigationParameters(),
                        useModalNavigation: false,
                        animated: true,
                        wrapIntoNav: false
                    )
                }
            }
            
            Button("Main") {
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
            
            Button("multi Push root DetailsPage/AddEditPage")
            {
                Task
                {
                    try await SwiftUIPageNavigationService.shared.Navigate(
                        name: "/MovieDetailPageViewModel/AddEditMoviePageViewModel",
                        parameters: NavigationParameters(),
                        useModalNavigation: false,
                        animated: true,
                        wrapIntoNav: false)
                }
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoginPage()
}
