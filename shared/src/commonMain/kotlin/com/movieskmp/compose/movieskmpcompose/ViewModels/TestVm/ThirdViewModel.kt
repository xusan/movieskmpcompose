package com.movieskmp.compose.movieskmpcompose.ViewModels.TestVm

import com.app.shared.Base.AppPageViewModel
import com.app.shared.Base.PageInjectedServices

class ThirdViewModel(injectedService: PageInjectedServices) : AppPageViewModel(injectedService)
{
    suspend fun NavigateToRoot()
    {
        Services.NavigationService.NavigateToRoot()
    }

    suspend fun NavigateToSecondRoot()
    {
        Navigate("/${SecondViewModel::class.simpleName}")
    }
}