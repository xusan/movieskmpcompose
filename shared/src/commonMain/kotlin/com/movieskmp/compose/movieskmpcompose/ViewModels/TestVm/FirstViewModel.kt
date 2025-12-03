package com.movieskmp.compose.movieskmpcompose.ViewModels.TestVm

import com.app.shared.Base.AppPageViewModel
import com.app.shared.Base.PageInjectedServices
import com.base.mvvm.Navigation.INavigationParameters

class FirstViewModel(injectedService: PageInjectedServices) : AppPageViewModel(injectedService)
{
    var Message: String = "First Page"
        set(value)
        {
            SetProperty(::Message.name, field, value) { field = it }
        }

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

    var index = 1;
    fun UpdateMessage()
    {
        index++
        Message = "First Page $index"
    }

}