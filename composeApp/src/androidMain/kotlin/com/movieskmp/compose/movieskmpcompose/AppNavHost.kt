package com.movieskmp.compose.movieskmpcompose

import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.movieskmp.compose.movieskmpcompose.Impl.mvvm.BasePage
import com.movieskmp.compose.movieskmpcompose.Impl.mvvm.ComposeNavRegistrar
import com.movieskmp.compose.movieskmpcompose.Impl.mvvm.ComposeNavigationService
import com.movieskmp.compose.movieskmpcompose.Impl.mvvm.NavPage

@Composable
fun AppNavHost(nav: ComposeNavigationService, start: String) {
    val navController = rememberNavController()

    LaunchedEffect(Unit) {
        nav.navController = navController
    }

    val stack = nav.stateStack

    NavHost(navController, start) {
        ComposeNavRegistrar.map.forEach { (route, entry) ->
            composable(route) { _ ->

                val params = nav.consumeParams()

                // Create VM ONLY when this destination is active
                val page = remember(stack.size)
                {
                    val vm = ComposeNavRegistrar.CreateViewModelFromEntry(entry, params)
                    val navPage = NavPage(route, vm)
                    nav.pushPage(navPage)
                    navPage
                }

                BasePage(page.vm) {
                    entry.viewFactory(page.vm)
                }
            }
        }
    }
}