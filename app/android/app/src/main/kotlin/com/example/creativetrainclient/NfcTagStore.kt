package com.example.creativetrainclient

import android.util.Log
import org.json.JSONObject

object NfcTagStore {

    private const val TAG = "NFC_TAG_STORE"

    private var sessionUuid: String? = null

    private var playerUuid: String? = null
    private var challenge: String? = null

    // -------------------------
    // SESSION UUID TAG
    // -------------------------

    fun setSessionUuid(value: String) {
        sessionUuid = value
        Log.d(TAG, "sessionuuid set: $value")
    }

    fun clearSessionUuid() {
        sessionUuid = null
        Log.d(TAG, "sessionuuid cleared")
    }

    fun getSessionUuidJson(): String? {
        val value = sessionUuid ?: return null

        return JSONObject()
            .put("sessionuuid", value)
            .toString()
    }

    // -------------------------
    // PLAYER INFO TAG
    // -------------------------

    fun setPlayerInfo(
        playerUuidValue: String,
        challengeValue: String
    ) {
        playerUuid = playerUuidValue
        challenge = challengeValue

        Log.d(TAG, "playerInfo set")
        Log.d(TAG, "playeruuid: $playerUuidValue")
        Log.d(TAG, "challenge: $challengeValue")
    }

    fun clearPlayerInfo() {
        playerUuid = null
        challenge = null
        Log.d(TAG, "playerInfo cleared")
    }

    fun getPlayerInfoJson(): String? {
        val uuid = playerUuid ?: return null
        val challengeValue = challenge ?: return null

        return JSONObject()
            .put("playeruuid", uuid)
            .put("challenge", challengeValue)
            .toString()
    }

    // -------------------------
    // CLEAR EVERYTHING
    // -------------------------

    fun clearAll() {
        sessionUuid = null
        playerUuid = null
        challenge = null

        Log.d(TAG, "all NFC tags cleared")
    }
}