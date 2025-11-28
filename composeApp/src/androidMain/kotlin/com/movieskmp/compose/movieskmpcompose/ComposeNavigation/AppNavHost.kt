package com.movieskmp.compose.movieskmpcompose.ComposeNavigation

import androidx.compose.animation.core.tween
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.unit.IntOffset
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.movieskmp.compose.movieskmpcompose.Impl.mvvm.BasePage
import com.movieskmp.compose.movieskmpcompose.Impl.mvvm.ComposeNavRegistrar
import com.movieskmp.compose.movieskmpcompose.Impl.mvvm.DroidPageNavigationService
import com.movieskmp.compose.movieskmpcompose.Impl.mvvm.NavPage

@Composable
fun AppNavHost(nav: DroidPageNavigationService, start: String) {
    val navController = rememberNavController()

    LaunchedEffect(Unit) {
        nav.navController = navController
    }

    //val stack = nav.stateStack
    val animationDuration = tween<IntOffset>(300)

    NavHost(navController, start,
        enterTransition = {
            slideInHorizontally(
                initialOffsetX = { it },        // from right
                animationSpec = animationDuration
            )
        },
        exitTransition = {
            slideOutHorizontally(
                targetOffsetX = { -it / 3 },    // slight left
                animationSpec = animationDuration
            )
        },
        popEnterTransition = {
            slideInHorizontally(
                initialOffsetX = { -it / 3 },   // from left (pop)
                animationSpec = animationDuration
            )
        },
        popExitTransition = {
            slideOutHorizontally(
                targetOffsetX = { it },         // to right
                animationSpec = animationDuration
            )
        })
    {
        ComposeNavRegistrar.map.forEach { (route, entry) ->
            composable(route) { backStackEntry  ->

                val entryId = backStackEntry.id
                val pageViewModel = nav.GetOrCreateViewModel(entryId, route)
                BasePage(pageViewModel) {
                    entry.viewFactory(pageViewModel)
                }
            }
        }
    }
}