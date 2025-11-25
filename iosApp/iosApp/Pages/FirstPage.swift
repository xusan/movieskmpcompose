//
//  FirstPage.swift
//  iosApp
//
//  Created by xasan on 25/11/25.
//
import SwiftUI

struct FirstPage: View {
    var vm: FirstViewModel
    
    var body: some View
    {
        VStack(spacing: 15)
        {
            Text("1").font(.system(size: 120))
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button("navigate to SecondPage") {
                print("Button was tapped")
                vm.NavigateToSecond()
            }
        }
        .padding()
    }
}


#Preview {    
    FirstPage(vm: FirstViewModel(injectedService: PageInjectedServices()))
}
