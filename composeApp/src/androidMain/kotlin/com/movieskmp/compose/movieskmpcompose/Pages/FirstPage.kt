package com.movieskmp.compose.movieskmpcompose.Pages

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.sp
import com.app.shared.Base.PageInjectedServices
import com.movieskmp.compose.movieskmpcompose.Impl.mvvm.LocalEventBus
import com.movieskmp.compose.movieskmpcompose.ViewModels.TestVm.FirstViewModel
import kotlinx.coroutines.launch
import org.jetbrains.compose.ui.tooling.preview.Preview

@Composable
fun FirstPage(vm: FirstViewModel)
{
    var message by remember { mutableStateOf(vm.Message) }
    val eventBus = LocalEventBus.current
    LaunchedEffect(Unit) {
        eventBus.events.collect { event ->
            println("eventBus.events.collect(): property = ${event.propertyName}")
            if(event.propertyName == "Message")
            {
                message = vm.Message
            }
        }
    }
    Column(Modifier.fillMaxSize().background(Color.Cyan), Arrangement.Center, Alignment.CenterHorizontally) {
        val scope = rememberCoroutineScope()

        Text("Sample Binding: $message")//One way
        Text("1", fontSize = 50.sp)
        Button(onClick ={
                scope.launch()
                {
                    vm.navigateToSecond()
                }
            })
        {
            Text("Go to Second")
        }
        Button(onClick = { vm.UpdateMessage() })
        {
            Text("Update Message")
        }
    }
}

@Preview
@Composable
fun FirstPage_Preview() {
    FirstPage(vm = FirstViewModel(PageInjectedServices())) // or fake VM
}

