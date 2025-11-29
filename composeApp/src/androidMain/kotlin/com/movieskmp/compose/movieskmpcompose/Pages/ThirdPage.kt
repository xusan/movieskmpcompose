package com.movieskmp.compose.movieskmpcompose.Pages

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.sp
import com.app.shared.Base.PageInjectedServices
import com.base.mvvm.ViewModels.InjectedService
import com.movieskmp.compose.movieskmpcompose.ViewModels.TestVm.FirstViewModel
import com.movieskmp.compose.movieskmpcompose.ViewModels.TestVm.SecondViewModel
import com.movieskmp.compose.movieskmpcompose.ViewModels.TestVm.ThirdViewModel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import org.jetbrains.compose.ui.tooling.preview.Preview

@Composable
fun ThirdPage(vm: ThirdViewModel) {
    Column(Modifier
        .fillMaxSize()
        .background(Color.Yellow), Arrangement.Center, Alignment.CenterHorizontally)
    {
        val scope = rememberCoroutineScope()

        Text("3", fontSize = 92.sp)
        Button(onClick = { btnNavigateToRoot_Clicked3(vm, scope) })
        {
            Text("NavigateToRoot ../../")
        }
        Button(onClick = { btnMakeRoot_Clicked3(vm, scope) })
        {
            Text("/SecondViewModel (make root)")
        }
        Button(onClick = { btnBack_Clicked3(vm, scope) })
        {
            Text("Back")
        }
    }
}

fun btnNavigateToRoot_Clicked3(vm: ThirdViewModel, scope: CoroutineScope)
{
    scope.launch()
    {
        vm.NavigateToRoot()
    }
}

fun btnMakeRoot_Clicked3(vm: ThirdViewModel, scope: CoroutineScope)
{
    scope.launch()
    {
        vm.NavigateToSecondRoot()
    }
}

fun btnBack_Clicked3(vm: ThirdViewModel, scope: CoroutineScope)
{
    scope.launch()
    {
        vm.NavigateBack()
    }
}

@Preview
@Composable
fun ThirdPage_Preview() {
    ThirdPage(vm = ThirdViewModel(PageInjectedServices())) // or fake VM
}
