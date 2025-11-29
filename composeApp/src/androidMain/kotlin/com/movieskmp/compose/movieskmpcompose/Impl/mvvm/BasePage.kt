package com.movieskmp.compose.movieskmpcompose.Impl.mvvm

import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.platform.LocalLifecycleOwner
import com.base.mvvm.ViewModels.PageViewModel

@Composable
fun <VM : PageViewModel> BasePage(viewModel: VM,content: @Composable () -> Unit)
{
    val lifecycleOwner = LocalLifecycleOwner.current
    val currentVm by rememberUpdatedState(viewModel)
    val eventBus = LocalEventBus.current

    println("BasePage eventBus instance: $eventBus")
    println("BasePage eventBus.hash: ${eventBus.hashCode()}")
    DisposableEffect(lifecycleOwner)
    {
        val ViewModel_OnPropertyChanged = { prop: String ->

            val result = eventBus.events.tryEmit(PropertyChangedEvent(prop))
            print("eventBus.events.tryEmit() result = $result")
        }

        val observer = LifecycleEventObserver()
        { _, event ->

            if (event == Lifecycle.Event.ON_CREATE)
            {
                viewModel.PropertyChanged += ViewModel_OnPropertyChanged
            }
            else if (event == Lifecycle.Event.ON_DESTROY)
            {
                viewModel.PropertyChanged -= ViewModel_OnPropertyChanged
            }
            else if (event == Lifecycle.Event.ON_START)
            {
                currentVm.OnAppearing()

            }
            else if (event == Lifecycle.Event.ON_STOP)
            {
                currentVm.OnDisappearing()
            }
        }



        lifecycleOwner.lifecycle.addObserver(observer)

        onDispose {
            lifecycleOwner.lifecycle.removeObserver(observer)
        }
    }

    content()
}



data class PropertyChangedEvent(val propertyName: String)

