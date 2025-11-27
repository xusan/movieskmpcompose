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

    DisposableEffect(lifecycleOwner)
    {
        val observer = LifecycleEventObserver()
        { _, event ->

            when (event) {
                Lifecycle.Event.ON_START -> currentVm.OnAppeared()
                Lifecycle.Event.ON_STOP  -> currentVm.OnDisappearing()
                else -> Unit
            }
        }

        lifecycleOwner.lifecycle.addObserver(observer)

        onDispose {
            lifecycleOwner.lifecycle.removeObserver(observer)
        }
    }

    content()
}