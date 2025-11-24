package com.movieskmp.compose.movieskmpcompose

interface Platform
{
    val name: String
}

expect fun getPlatform(): Platform