//
//  DetailsPage.swift
//  iosApp
//
//  Created by xusan on 24/11/25.
//

import SharedAppCore
import SwiftUI

struct DetailsPage: View {
    @EnvironmentObject var adapter: ViewModelObservable
    var vm: MovieDetailPageViewModel { adapter.Vm as! MovieDetailPageViewModel }
    
    @StateObject private var alertService = Sui_AlertDialogService.shared
    

    var body: some View {
        VStack(spacing: 20) {
            Text("Details").font(.largeTitle)

            
            Button("Show alert")
            {
                Task
                {
                    do
                    {
//                        try await alertService.DisplayAlert(
//                            title: "Test",
//                            message: "Test Message",
//                            cancel: "Close"
//                        )
                        
                       
                        
                        let vm = try KoinResolver()
                            .GetNavigationService()
                            .GetRootPageModel() as? MoviesPageViewModel
                        
                        let item = MenuItem()
                        item.Type = .logout
                        vm?.MenuTappedCommand.Execute(param: item)
                    }
                    catch
                    {
                        print("Error: \(error)")
                    }
                }
            }
        }
        .alert("Sample alert", isPresented: $alertService.isShowAlert) {
                    // Custom "Yes" button (default prominence)
                    Button("Yes") {
                        //viewModel.performYesAction()
                    }
                    
                    // Custom "No" button with a cancel role
                    Button("No", role: .cancel) {
                        //viewModel.performNoAction()
                    }
                } message: {
                    Text("Alert message here")
                }
    }
}

#Preview {
    DetailsPage()
}
