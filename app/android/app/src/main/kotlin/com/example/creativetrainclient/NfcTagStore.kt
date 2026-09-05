package com.example.creativetrainclient

import org.json.JSONObject

object NfcTagStore {

// ============================================================
// SESSION UUID
// ============================================================

@Volatile
private var sessionUuid: String? = null

// ============================================================
// PLAYER INFO
// ============================================================

@Volatile
private var playerUuid: String? = null

@Volatile
private var challenge: String? = null

// ============================================================
// SESSION UUID
// ============================================================

@Synchronized
fun setSessionUuid(
value: String
) {
sessionUuid = value
}

@Synchronized
fun getSessionUuidJson(): String? {

val value = sessionUuid
?: return null

return JSONObject()
    .put(
"sessionUuid",
value
)
    .toString()
}

@Synchronized
fun clearSessionUuid() {
sessionUuid = null
}

// ============================================================
// PLAYER INFO
// ============================================================

@Synchronized
fun setPlayerInfo(
playerUuidValue: String,
challengeValue: String
) {
playerUuid = playerUuidValue
challenge = challengeValue
}

@Synchronized
fun getPlayerInfoJson(): String? {

val player =
playerUuid
?: return null

val challengeValue =
challenge
?: return null

return JSONObject()
    .put(
"playerUuid",
player
)
    .put(
"challenge",
challengeValue
)
    .toString()
}

@Synchronized
fun clearPlayerInfo() {
playerUuid = null
challenge = null
}

// ============================================================
// CLEAR EVERYTHING
// ============================================================

@Synchronized
fun clearAll() {
sessionUuid = null
playerUuid = null
challenge = null
}
}