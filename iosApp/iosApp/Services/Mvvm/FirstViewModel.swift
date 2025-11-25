//
//  FirstViewModel.swift
//  iosApp
//
//  Created by xasan on 25/11/25.
//
import SharedAppCore

class FirstViewModel : PageViewModel
{       
    let Name : String = "First View Model"
    
    func NavigateToSecond()
    {
        Task
        {
            do
            {
                try await Navigate(name: "SecondViewModel")
            }
            catch
            {
                print("Navigation to SecondViewModel failed with error: \(error)")
            }
            
        }
    }
    
}

extension PageViewModel
{
    func Navigate(name: String) async throws
    {
        print("PageViewModel.Navigate() is called with name: \(name)")
        try await Navigate(name: name, parameters: NavigationParameters(), useModalNavigation: false, animated: true, wrapIntoNav: false)
    }
}
