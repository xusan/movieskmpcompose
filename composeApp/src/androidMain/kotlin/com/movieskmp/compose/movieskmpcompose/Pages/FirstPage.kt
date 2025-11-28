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
import com.movieskmp.compose.movieskmpcompose.ViewModels.TestVm.FirstViewModel
import kotlinx.coroutines.launch
import org.jetbrains.compose.ui.tooling.preview.Preview

@Composable
@Preview
fun FirstPage(vm: FirstViewModel)
{
    Column(Modifier.fillMaxSize().background(Color.Cyan), Arrangement.Center, Alignment.CenterHorizontally) {
        val scope = rememberCoroutineScope()

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
    }
}