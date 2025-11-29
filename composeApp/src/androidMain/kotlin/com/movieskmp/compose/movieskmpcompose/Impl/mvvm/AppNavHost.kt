package com.movieskmp.compose.movieskmpcompose.Impl.mvvm

import androidx.compose.animation.core.tween
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.runtime.remember
import androidx.compose.ui.unit.IntOffset
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import kotlinx.coroutines.flow.MutableSharedFlow

@Composable
fun AppNavHost(nav: DroidPageNavigationService, start: String)
{
    //setup navigation controller
    val navController = rememberNavController()
    LaunchedEffect(Unit) {
        nav.navController = navController
    }

    //Wrap NavHost with the provider to have LocalEventBus for all views
    val eventBus = remember { EventBus() }
    CompositionLocalProvider(LocalEventBus provides eventBus)
    {
        val animationDuration = tween<IntOffset>(300)

        //NavHost: navigation with iOS like animation
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
            //declare all registered pages as navigation routes
            ComposeNavRegistrar.map.forEach { (route, entry) ->
                composable(route) { backStackEntry  ->

                    val entryId = backStackEntry.id
                    val pageViewModel = nav.GetOrCreateViewModel(entryId, route)
                    BasePage(pageViewModel) {
                        //show the child-composable view
                        entry.viewFactory(pageViewModel)
                    }
                }
            }
        }
    }

}


val LocalEventBus = compositionLocalOf<EventBus> {
    error("EventBus not provided")
}

class EventBus {
    val events = MutableSharedFlow<PropertyChangedEvent>(
        replay = 1,                 // replay last event to late subscribers
        extraBufferCapacity = 10    // avoid drops
    )
}