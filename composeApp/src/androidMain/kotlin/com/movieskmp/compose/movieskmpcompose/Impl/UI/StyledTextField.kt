package com.movieskmp.compose.movieskmpcompose.Impl.UI

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun StyledTextField(
    value: String,
    onValueChange: (String) -> Unit,
    hint: String,
    isPassword: Boolean = false
) {
    var isFocused by remember { mutableStateOf(false) }

    val borderColor = if (isFocused) BlueColor else Color.Transparent
    val borderWidth = 2.dp

    val visualTransformation =
        if (isPassword) PasswordVisualTransformation()
        else VisualTransformation.None

    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        placeholder = { Text(hint) },
        textStyle = LocalTextStyle.current.copy(fontSize = 16.sp),
        visualTransformation = visualTransformation,
        modifier = Modifier
            .fillMaxWidth()
            .height(50.dp)
            .onFocusChanged { isFocused = it.isFocused }
            .border(
                width = borderWidth,
                color = borderColor,
                shape = RoundedCornerShape(25.dp)
            )
            .background(Color.White, RoundedCornerShape(25.dp)),
        singleLine = true,
        colors = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = Color.Transparent,
            unfocusedBorderColor = Color.Transparent,
            disabledBorderColor = Color.Transparent
        )
    )
}