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
    
    var body: some View
    {
        VStack(spacing: 16)
        {
            Sui_EditTextField(
                text: $username,
                placeholder: "Login"
            )
            
            Sui_EditTextField(
                text: $password,
                placeholder: "Password",
                isPassword: true
            )
            
            Sui_PrimaryButton(text: "Submit")
            {
                Vm.Login = username
                Vm.Password = password
                Vm.SubmitCommand.Execute()
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity,
               maxHeight: .infinity,
               alignment: .center)        
    }
}

#Preview {
    LoginPage()
}
