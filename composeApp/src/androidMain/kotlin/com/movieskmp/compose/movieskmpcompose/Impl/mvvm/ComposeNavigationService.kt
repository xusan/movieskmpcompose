package com.movieskmp.compose.movieskmpcompose.Impl.mvvm

import androidx.compose.runtime.mutableStateListOf
import androidx.navigation.NavHostController
import com.base.mvvm.Navigation.INavigationParameters
import com.base.mvvm.Navigation.IPage
import com.base.mvvm.Navigation.IPageNavigationService
import com.base.mvvm.Navigation.NavigationParameters
import com.base.mvvm.Navigation.UrlNavigationHelper
import com.base.mvvm.ViewModels.PageViewModel

class ComposeNavigationService : IPageNavigationService
{

    lateinit var navController: NavHostController
    //private set

    private val pages = mutableListOf<NavPage>()      // VM stack
    val stateStack = mutableStateListOf<NavPage>()   // exposed to Compose UI

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
        val vm = pages.firstOrNull()?.vm
        return vm
    }

    override fun GetNavStackModels(): List<PageViewModel>
    {
        val viewModels = pages.map { x -> x.vm }
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
        repeat(pages.size - 1) {
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
        val popped = popPage()
        popped?.vm?.OnNavigatedFrom(params)
        popped?.vm?.Destroy()

        // Now notify next VM
        currentVm()?.OnNavigatedTo(params)

        navController.popBackStack()
    }

    fun OnMultiPopAsync(url: String, params: INavigationParameters)
    {
        val count = url.countMatches("../")

        repeat(count) {
            val popped = popPage()
            popped?.vm?.OnNavigatedFrom(params)
            popped?.vm?.Destroy()
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
            val popped = popPage()
            popped?.vm?.OnNavigatedFrom(NavigationParameters())
            popped?.vm?.Destroy()
            navController.popBackStack()
        }

        pendingParams = params
        navController.navigate(vmName)
    }


    fun OnPushRootAsync(url: String, params: INavigationParameters)
    {
        val vmName = url.replace("/", "")

        pages.forEach { it.vm.Destroy() }
        pages.clear()

        pendingParams = params

        navController.navigate(vmName) {
            popUpTo(0) { inclusive = true }
        }
    }


    fun OnMultiPushRootAsync(url: String, params: INavigationParameters)
    {
        val names = url.split("/").filter { it.isNotBlank() }

        pages.forEach { it.vm.Destroy() }
        pages.clear()

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

    // Kotlin extension
    private fun String.countMatches(sub: String): Int = this.split(sub).size - 1

    fun pushPage(page: NavPage)
    {
        pages.add(page)
        syncState()
    }

    fun popPage(): NavPage?
    {
        val p = pages.removeLastOrNull()
        syncState()
        return p
    }

    fun currentPage(): NavPage? = pages.lastOrNull()

    fun currentVm(): PageViewModel? = currentPage()?.vm

    fun consumeParams(): INavigationParameters
    {
        val p = pendingParams ?: NavigationParameters()
        pendingParams = null
        return p
    }

    private fun syncState()
    {
        stateStack.clear()
        stateStack.addAll(pages)
    }
}

data class NavPage(
    val vmName: String,
    val vm: PageViewModel,
)

data class Page(override var ViewModel: PageViewModel) : IPage