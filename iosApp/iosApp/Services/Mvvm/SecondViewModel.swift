//
//  SecondViewModel.swift
//  iosApp
//
//  Created by xasan on 25/11/25.
//


class SecondViewModel : PageViewModel
{
    let Name : String = "Second View Model"
    
    func BackCommand()
    {
        Task
        {
            try! await Navigate(name: "../")
        }
    }
    
    func NavigateToThird()
    {
        Task
        {
            try! await Navigate(name: "ThirdViewModel")
        }
    }
}