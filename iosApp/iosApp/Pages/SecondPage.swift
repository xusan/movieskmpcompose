//
//  SecondPage.swift
//  iosApp
//
//  Created by xasan on 25/11/25.
//


import SwiftUI

struct SecondPage: View
{
    var vm: SecondViewModel
    
    var body: some View
    {
        VStack(spacing: 15)
        {
            Text("2").font(.system(size: 120))
            Text("Second page!")
//            Button("Navigate to 3") {
//                
//                vm.NavigateToThird()
//            }
        }
        .padding()
    }
}


#Preview {
    SecondPage(vm: SecondViewModel(injectedService: PageInjectedServices()))
}
