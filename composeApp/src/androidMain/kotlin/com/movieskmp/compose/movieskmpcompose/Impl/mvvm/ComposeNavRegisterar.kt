package com.movieskmp.compose.movieskmpcompose.Impl.mvvm

import androidx.compose.runtime.Composable
import com.base.mvvm.Navigation.INavigationParameters
import com.base.mvvm.ViewModels.PageViewModel


data class NavEntry(
    val vmFactory: () -> PageViewModel,
    val viewFactory: @Composable (PageViewModel) -> Unit
)

object ComposeNavRegistrar {
    public val map = mutableMapOf<String, NavEntry>()

    inline fun <reified VM : PageViewModel> Register(
        noinline vmFactory: () -> VM,
        noinline viewFactory: @Composable (VM) -> Unit
    ) {
        val name = VM::class.simpleName!!
        map[name] = NavEntry(
            vmFactory = { vmFactory() },
            viewFactory = { vm -> viewFactory(vm as VM) }
        )
    }


    fun CreateViewModelFromEntry(entry: NavEntry, params: INavigationParameters): PageViewModel
    {
        val vm = entry.vmFactory().apply {
            Initialize(params)
            OnNavigatedTo(params)
        }

        return vm
    }

//    fun Get(vmName: String) = map[vmName]!!
//    fun CreatePage(vmName: String, params: INavigationParameters): NavPage
//    {
//        val entry = Get(vmName)
//
//        val vm = entry.vmFactory().apply {
//            Initialize(params)
//            OnNavigatedTo(params)
//        }
//
//        return NavPage(vmName, vm)
//    }


}