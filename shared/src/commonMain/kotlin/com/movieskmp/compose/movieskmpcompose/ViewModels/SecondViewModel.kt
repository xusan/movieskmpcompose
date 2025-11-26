package com.movieskmp.compose.movieskmpcompose.ViewModels

import com.app.shared.Base.AppPageViewModel
import com.app.shared.Base.PageInjectedServices
import com.base.mvvm.Navigation.INavigationParameters
import com.base.mvvm.Navigation.IPageNavigationService

class SecondViewModel(injectedService: PageInjectedServices) : AppPageViewModel(injectedService)
{
    var message = "Second Page"

    override fun OnNavigatedTo(parameters: INavigationParameters)
    {
        println("SecondViewModel")
    }

    suspend fun navigateBack()
    {
        NavigateBack()
    }
}