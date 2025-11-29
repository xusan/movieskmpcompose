package com.movieskmp.compose.movieskmpcompose.ViewModels.TestVm

import com.app.shared.Base.AppPageViewModel
import com.app.shared.Base.PageInjectedServices
import com.base.mvvm.Navigation.INavigationParameters

class SecondViewModel(injectedService: PageInjectedServices) : AppPageViewModel(injectedService)
{
    var message = "Second Page"

    override fun OnNavigatedTo(parameters: INavigationParameters)
    {
        println("SecondViewModel")
    }

    suspend fun NavigateToThird()
    {
        Navigate("${ThirdViewModel::class.simpleName}")
    }

    suspend fun PopAndNavigateToThird()
    {
        Navigate("../${ThirdViewModel::class.simpleName}")
    }
}