package com.movieskmp.compose.movieskmpcompose

import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import androidx.lifecycle.lifecycleScope
import com.base.abstractions.Diagnostic.ILoggingService
import com.base.impl.ContainerLocator
import com.example.movieskmp.Bootstrap
import com.movieskmp.compose.movieskmpcompose.Impl.mvvm.ComposeNavigationService
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity()
{
    private lateinit var loggingService: ILoggingService

    override fun onCreate(savedInstanceState: Bundle?)
    {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        val navService = ComposeNavigationService()
        val bootstrap = Bootstrap(this)
        bootstrap.RegisterTypes(navService)

        setContent {
            App()
        }



//        binding.apply {
//            pageNavigationService = navContainer
//            bootstrap.RegisterTypes(pageNavigationService)
//        }

        this.loggingService = ContainerLocator.Resolve<ILoggingService>()
        this.loggingService.Log("####################################################- APPLICATION STARTED -####################################################");
        this.loggingService.Log("MainActivity.OnCreate()");

//        lifecycleScope.launch() {
//            bootstrap.NavigateToPageAsync(pageNavigationService);
//        }

        window.setSoftInputMode(
            WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN
        )
    }
}

@Preview @Composable fun AppAndroidPreview()
{
    App()
}