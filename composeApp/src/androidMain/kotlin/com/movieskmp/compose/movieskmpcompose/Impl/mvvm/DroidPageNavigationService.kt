package com.movieskmp.compose.movieskmpcompose.Impl.mvvm

import androidx.compose.runtime.mutableStateListOf
import androidx.navigation.NavHostController
import com.base.mvvm.Navigation.INavigationParameters
import com.base.mvvm.Navigation.IPage
import com.base.mvvm.Navigation.IPageNavigationService
import com.base.mvvm.Navigation.NavigationParameters
import com.base.mvvm.Navigation.UrlNavigationHelper
import com.base.mvvm.ViewModels.PageViewModel
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class DroidPageNavigationService : IPageNavigationService
{

    lateinit var navController: NavHostController
    //private set

    val statePages = mutableStateListOf<NavPage>()      // VM stack

    private var pendingParams: INavigationParameters? = null

    override val CanNavigateBack: Boolean
        get() = TODO("Not yet implemented")

    override fun GetCurrentPage(): IPage?
    {
        val vm = currentVm()
        return vm?.let { Page(it) }
    }

    override fun GetCurrentPageModel(): PageViewModel?
    {
        return currentVm()
    }

    override fun GetRootPageModel(): PageViewModel?
    {
        val vm = statePages.firstOrNull()?.vm
        return vm
    }

    override fun GetNavStackModels(): List<PageViewModel>
    {
        val viewModels = statePages.map { x -> x.vm }
        return viewModels
    }

    // Main URL-based entry point
    override suspend fun Navigate(name: String, parameters: INavigationParameters?,
                         useModalNavigation: Boolean,
                         animated: Boolean,
                         wrapIntoNav: Boolean)
    {
        val navInfo = UrlNavigationHelper.Parse(name)
        val params = parameters ?: NavigationParameters()

        when
        {
            navInfo.isPush ->
            {
                OnPushAsync(name, params)
            }
            navInfo.isPop ->
            {
                OnPopAsync(params)
            }
            navInfo.isMultiPop ->
            {
                OnMultiPopAsync(name, params)
            }
            navInfo.isMultiPopAndPush ->
            {
                OnMultiPopAndPush(name, params)
            }
            navInfo.isPushAsRoot ->
            {
                OnPushRootAsync(name, params)
            }
            navInfo.isMultiPushAsRoot ->
            {
                OnMultiPushRootAsync(name, params)
            }
            else -> error("Navigation case is not implemented.")
        }
    }

    override suspend fun NavigateToRoot(parameters: INavigationParameters?)
    {
        var multiplePops = ""
        repeat(statePages.size - 1) {
            multiplePops += "../"
        }
        OnMultiPopAsync(multiplePops, parameters ?: NavigationParameters())
    }

    // Simple push (equivalent to Navigate("ScreenName"))
    fun OnPushAsync(vmName: String, params: INavigationParameters)
    {
        currentVm()?.OnNavigatedFrom(params)

        pendingParams = params
        navController.navigate(vmName)
    }

    fun OnPopAsync(params: INavigationParameters)
    {
        popPage()
        // Now notify next VM
        currentVm()?.OnNavigatedTo(params)

        navController.popBackStack()
    }

    fun OnMultiPopAsync(url: String, params: INavigationParameters)
    {
        val count = url.countMatches("../")

        repeat(count)
        {
            popPage()
        }

        currentVm()?.OnNavigatedTo(params)

        repeat(count) {
            navController.popBackStack()
        }
    }

    fun OnMultiPopAndPush(url: String, params: INavigationParameters)
    {
        val pops = url.countMatches("../")
        val vmName = url.replace("../", "")

        repeat(pops) {
            popPage()
            navController.popBackStack()
        }

        pendingParams = params
        navController.navigate(vmName)
    }


    fun OnPushRootAsync(url: String, params: INavigationParameters)
    {
        val vmName = url.replace("/", "")

        repeat(statePages.size) //remove except root
        {
            popPage()
            navController.popBackStack()
        }

        pendingParams = params

        navController.navigate(vmName) {
            popUpTo(0) { inclusive = true }
        }
    }


    fun OnMultiPushRootAsync(url: String, params: INavigationParameters)
    {
        val names = url.split("/").filter { it.isNotBlank() }

        repeat(statePages.size) //remove except root
        {
            popPage()
            navController.popBackStack()
        }

        pendingParams = params

        navController.navigate(names.first()) {
            popUpTo(0) { inclusive = true }
        }

        // push extra pages
        for (i in 1 until names.size)
        {
            navController.navigate(names[i])
        }
    }

    val viewModels = mutableMapOf<String, PageViewModel>()
    public fun GetOrCreateViewModel(entryId: String, vmName: String) : PageViewModel
    {
        val vm = viewModels[entryId]
        if(vm == null)
        {
            val newVm = ComposeNavRegistrar.CreateViewModel(vmName, pendingParams ?: NavigationParameters())
            pendingParams = null
            val navPage = NavPage(entryId, vmName, newVm)
            statePages.add(navPage)
            //cache vm
            viewModels[entryId] = newVm

            return newVm
        }
        else
        {
            return vm;
        }
    }

    // Kotlin extension
    private fun String.countMatches(sub: String): Int = this.split(sub).size - 1

    fun popPage(): NavPage?
    {
        val poppedPage = statePages.removeLastOrNull()
        poppedPage?.vm?.OnNavigatedFrom(NavigationParameters())

        GlobalScope.launch {
            //delay before remove: to make sure that the viewmodel is not used by compose anymore
            delay(300)
            viewModels.remove(poppedPage?.id)
            poppedPage?.vm?.Destroy()
        }
        return poppedPage
    }

    fun currentPage(): NavPage? = statePages.lastOrNull()

    fun currentVm(): PageViewModel? = currentPage()?.vm




}

data class NavPage(
    val id: String,
    val vmName: String,
    val vm: PageViewModel,
)

data class Page(override var ViewModel: PageViewModel) : IPage