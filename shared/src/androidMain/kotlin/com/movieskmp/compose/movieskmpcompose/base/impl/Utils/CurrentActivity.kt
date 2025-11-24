package com.base.impl.Droid.Utils

import android.app.Activity
import android.content.Context
import androidx.activity.ComponentActivity

object CurrentActivity
{
    private var activity: ComponentActivity? = null

    val Instance: ComponentActivity
        get() { return activity!!}

    var AppContext: Context? = null

    fun SetActivity(componentActivity: ComponentActivity)
    {
        activity = componentActivity;
        AppContext = componentActivity;
    }

    fun SetContext(context: Context)
    {
        AppContext = context
    }

}