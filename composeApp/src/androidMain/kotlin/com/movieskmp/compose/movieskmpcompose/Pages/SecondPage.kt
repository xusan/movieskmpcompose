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
import com.movieskmp.compose.movieskmpcompose.ViewModels.TestVm.FirstViewModel
import com.movieskmp.compose.movieskmpcompose.ViewModels.TestVm.SecondViewModel
import com.movieskmp.compose.movieskmpcompose.ViewModels.TestVm.ThirdViewModel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import org.jetbrains.compose.ui.tooling.preview.Preview

@Composable
fun SecondPage(vm: SecondViewModel) {
    Column(Modifier.fillMaxSize().background(Color.Yellow), Arrangement.Center, Alignment.CenterHorizontally)
    {
        val scope = rememberCoroutineScope()

        Text("2", fontSize = 92.sp)
        Button(onClick = { btnNavigateToThird_Clicked2(vm, scope) })
        {
            Text("ThirdViewModel")
        }
        Button(onClick = { btnPopNavigateThird_Clicked2(vm, scope) })
        {
            Text("../ThirdViewModel")
        }
        Button(onClick = { btnBack_Clicked2(vm, scope) })
        {
            Text("Back")
        }
    }
}

fun btnBack_Clicked2(vm: SecondViewModel, scope: CoroutineScope)
{
    scope.launch()
    {
        vm.NavigateBack()
    }
}

fun btnNavigateToThird_Clicked2(vm: SecondViewModel, scope: CoroutineScope)
{
    scope.launch()
    {
        vm.NavigateToThird()
    }
}

fun btnPopNavigateThird_Clicked2(vm: SecondViewModel, scope: CoroutineScope)
{
    scope.launch()
    {
        vm.PopAndNavigateToThird()
    }
}

@Preview
@Composable
fun SecondPage_Preview() {
    SecondPage(vm = SecondViewModel(PageInjectedServices())) // or fake VM
}

