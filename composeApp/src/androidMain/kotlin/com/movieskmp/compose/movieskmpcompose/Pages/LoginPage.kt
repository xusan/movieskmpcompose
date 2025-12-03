package com.movieskmp.compose.movieskmpcompose.Pages

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
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
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.app.shared.Base.PageInjectedServices
import com.app.shared.ViewModels.LoginPageViewModel
import com.movieskmp.compose.movieskmpcompose.Impl.UI.Gray100
import com.movieskmp.compose.movieskmpcompose.Impl.UI.PrimaryButton
import com.movieskmp.compose.movieskmpcompose.Impl.UI.StyledTextField
import com.movieskmp.compose.movieskmpcompose.Impl.mvvm.LocalEventBus
import kotlinx.coroutines.launch
import org.jetbrains.compose.ui.tooling.preview.Preview

@Composable
fun LoginPage(vm: LoginPageViewModel)
{
    var login by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Gray100)
    ) {
        Column(
            modifier = Modifier
                .padding(horizontal = 20.dp)
                .align(Alignment.Center)
        ) {
            StyledTextField(
                value = login,
                onValueChange = { login = it },
                hint = "Login"
            )

            Spacer(modifier = Modifier.height(15.dp))

            StyledTextField(
                value = password,
                onValueChange = { password = it },
                hint = "Password",
                isPassword = true
            )

            Spacer(modifier = Modifier.height(20.dp))

            PrimaryButton(
                text = "Submit",
                //enabled = login.isNotEmpty() && password.isNotEmpty()
            ) {
                vm.Login = login
                vm.Password = password
                vm.SubmitCommand.Execute()
            }
        }
    }
}

@Preview
@Composable
fun LoginPage_Preview()
{
    LoginPage(vm = LoginPageViewModel(PageInjectedServices())) // or fake VM
}