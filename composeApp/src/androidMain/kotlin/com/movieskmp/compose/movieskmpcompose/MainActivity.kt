package com.movieskmp.compose.movieskmpcompose

import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.base.abstractions.Diagnostic.ILoggingService
import com.base.impl.ContainerLocator
import com.movieskmp.compose.movieskmpcompose.Impl.mvvm.AppNavWithActionBar
import com.movieskmp.compose.movieskmpcompose.Impl.mvvm.DroidPageNavigationService

class MainActivity : ComponentActivity()
{
    private lateinit var loggingService: ILoggingService

    override fun onCreate(savedInstanceState: Bundle?)
    {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        val navService = DroidPageNavigationService()
        val bootstrap = Bootstrap(this)
        bootstrap.RegisterTypes(navService)

        this.loggingService = ContainerLocator.Resolve<ILoggingService>()
        this.loggingService.Log("####################################################- APPLICATION STARTED -####################################################");
        this.loggingService.Log("MainActivity.OnCreate()");

        val rootPage = bootstrap.GetRootPage()
        setContent {
            AppNavWithActionBar(navService, rootPage)
        }

        window.setSoftInputMode(
            WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN
        )
    }
}

//@Preview @Composable fun AppAndroidPreview()
//{
//    App()
//}