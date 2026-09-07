package com.example.creativetrainclient

import android.content.Context
import android.util.Log
import org.json.JSONObject

object NfcTagStore {

    private const val TAG = "NFC_TAG_STORE"
    private const val PREFS = "nfc_tag_prefs"

    fun setSessionUuid(context: Context, value: String?) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putString("sessionuuid", value).apply()
        Log.d(TAG, "sessionuuid updated: $value")
    }

    fun setPlayerUuid(context: Context, value: String?) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putString("playeruuid", value).apply()
        Log.d(TAG, "playeruuid updated: $value")
    }

    fun setChallenge(context: Context, value: String?) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putString("challenge", value).apply()
        Log.d(TAG, "challenge updated: $value")
    }

    fun clear(context: Context) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().clear().apply()
        Log.d(TAG, "NFC tag cleared")
    }

    fun getJson(context: Context): String {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        return JSONObject()
            .put("sessionuuid", prefs.getString("sessionuuid", null) ?: JSONObject.NULL)
            .put("playeruuid", prefs.getString("playeruuid", null) ?: JSONObject.NULL)
            .put("challenge", prefs.getString("challenge", null) ?: JSONObject.NULL)
            .toString()
    }
}