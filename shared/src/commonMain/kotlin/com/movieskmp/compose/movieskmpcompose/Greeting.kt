package com.movieskmp.compose.movieskmpcompose

class Greeting
{
    private val platform = getPlatform()

    fun greet(): String
    {
        return "Hello, ${platform.name}!"
    }
}