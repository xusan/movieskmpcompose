package com.movieskmp.compose.movieskmpcompose.ViewModels

import com.app.shared.Base.AppPageViewModel
import com.app.shared.Base.PageInjectedServices
import com.base.mvvm.Navigation.INavigationParameters
import com.base.mvvm.ViewModels.InjectedService
import com.base.mvvm.ViewModels.PageViewModel

class FirstViewModel(injectedService: PageInjectedServices) : AppPageViewModel(injectedService)
{
    var message = "First Page"

    override fun OnNavigatedTo(parameters: INavigationParameters)
    {
        super.OnNavigatedTo(parameters)

        println("FirstViewModel → OnNavigatedTo")
    }

    suspend fun navigateToSecond()
    {
        //val params = NavParams().apply { put("value", 123) }
        //injectedService..navigate("SecondViewModel", params)
        Navigate("SecondViewModel")
    }


}