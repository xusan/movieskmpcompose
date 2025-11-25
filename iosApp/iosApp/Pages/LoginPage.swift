//
//  LoginPage.swift
//  iosApp
//
//  Created by xusan on 24/11/25.
//
import SwiftUI


struct LoginPage: View {

    @EnvironmentObject var vmObs: PageViewModelObservable
    private var vm: LoginPageViewModel { vmObs.raw as! LoginPageViewModel }

    @State private var username = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Login").font(.largeTitle.bold())

            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            Button("Login") {
                vm.Login = username
                vm.Password = password
                vm.SubmitCommand.Execute()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(12)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoginPage()
}
