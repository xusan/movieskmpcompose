package com.movieskmp.compose.movieskmpcompose.ComposeNavigation

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import com.movieskmp.compose.movieskmpcompose.Impl.mvvm.DroidPageNavigationService
import kotlinx.coroutines.launch
//import androidx.compose.material.icons.Icons
//import androidx.compose.material.icons.filled.ArrowBack


@OptIn(ExperimentalMaterial3Api::class) @Composable
fun AppNavWithActionBar(nav: DroidPageNavigationService, start: String )
{

    val isRoot = nav.statePages.size <= 1
    val currentVm = nav.statePages.lastOrNull()?.vm
    val currentTitle = if(currentVm != null && currentVm.Title.isNotEmpty()) currentVm.Title else "Test Page"
    val scope = rememberCoroutineScope()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(currentTitle) },
                navigationIcon = {
                    if (!isRoot) {
                        IconButton(onClick = {
                            // navigate back
                            // use your existing pop logic
                            scope.launch { currentVm?.NavigateBack() }

                        }) {
                            Icon(
                                Icons.Default.ArrowBack,
                                contentDescription = "Back"
                            )
                        }
                    }
                }
            )
        }
    ) { padding ->
        Box(Modifier.padding(padding)) {
            AppNavHost(nav, start)
        }
    }
}