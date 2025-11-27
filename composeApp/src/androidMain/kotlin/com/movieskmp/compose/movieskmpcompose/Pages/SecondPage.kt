package com.movieskmp.compose.movieskmpcompose.Pages

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.movieskmp.compose.movieskmpcompose.ViewModels.FirstViewModel
import com.movieskmp.compose.movieskmpcompose.ViewModels.SecondViewModel
import kotlinx.coroutines.launch
import org.jetbrains.compose.ui.tooling.preview.Preview

@Composable
@Preview
fun SecondPage(vm: SecondViewModel) {
    Column(Modifier.fillMaxSize(), Arrangement.Center, Alignment.CenterHorizontally)
    {
        val scope = rememberCoroutineScope()

        Text(vm.message)
        Button(onClick ={
            scope.launch()
            {
                vm.navigateBack()
            }
        })
        {
            Text("Go to Second")
        }
    }
}