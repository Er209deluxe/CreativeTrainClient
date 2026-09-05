package com.example.creativetrainclient

import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.IsoDep
import android.os.Bundle
import android.util.Log

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {

        private const val CHANNEL = "nfc_peer"

        private const val TAG = "NFC_READER"

        // ============================================================
        // TAG IDS
        // ============================================================

        private const val TAG_SESSION_UUID = 0x01
        private const val TAG_PLAYER_INFO = 0x02
    }

    private var methodChannel: MethodChannel? = null

    private var nfcAdapter: NfcAdapter? = null

    // ================================================================
    // ACTIVITY
    // ================================================================

    override fun onCreate(
        savedInstanceState: Bundle?
    ) {
        super.onCreate(
            savedInstanceState
        )

        nfcAdapter =
            NfcAdapter.getDefaultAdapter(
                this
            )

        Log.d(
            TAG,
            "MAIN ACTIVITY CREATED"
        )
    }

    // ================================================================
    // FLUTTER CHANNEL
    // ================================================================

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {

        super.configureFlutterEngine(
            flutterEngine
        )

        Log.d(
            TAG,
            "REGISTERING METHOD CHANNEL: $CHANNEL"
        )

        methodChannel =
            MethodChannel(
                flutterEngine
                    .dartExecutor
                    .binaryMessenger,
                CHANNEL
            )

        methodChannel?.setMethodCallHandler {
                call,
                result ->

            Log.d(
                TAG,
                "METHOD CALLED: ${call.method}"
            )

            when (call.method) {

                // ========================================================
                // SESSION UUID
                // ========================================================

                "setSessionUuid" -> {

                    val sessionUuid =
                        call.argument<String>(
                            "sessionUuid"
                        )

                    if (sessionUuid == null) {

                        result.error(
                            "INVALID_ARGUMENT",
                            "sessionUuid is required",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    Log.d(
                        TAG,
                        "SETTING sessionUuid TAG"
                    )

                    NfcTagStore.setSessionUuid(
                        sessionUuid
                    )

                    result.success(null)
                }

                "clearSessionUuid" -> {

                    Log.d(
                        TAG,
                        "CLEARING sessionUuid TAG"
                    )

                    NfcTagStore
                        .clearSessionUuid()

                    result.success(null)
                }

                // ========================================================
                // PLAYER INFO
                // ========================================================

                "setPlayerInfo" -> {

                    val playerUuid =
                        call.argument<String>(
                            "playerUuid"
                        )

                    val challenge =
                        call.argument<String>(
                            "challenge"
                        )

                    if (playerUuid == null) {

                        result.error(
                            "INVALID_ARGUMENT",
                            "playerUuid is required",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    if (challenge == null) {

                        result.error(
                            "INVALID_ARGUMENT",
                            "challenge is required",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    Log.d(
                        TAG,
                        "SETTING playerInfo TAG"
                    )

                    NfcTagStore.setPlayerInfo(
                        playerUuid,
                        challenge
                    )

                    result.success(null)
                }

                "clearPlayerInfo" -> {

                    Log.d(
                        TAG,
                        "CLEARING playerInfo TAG"
                    )

                    NfcTagStore
                        .clearPlayerInfo()

                    result.success(null)
                }

                // ========================================================
                // CLEAR ALL
                // ========================================================

                "clearTags" -> {

                    Log.d(
                        TAG,
                        "CLEARING ALL NFC TAGS"
                    )

                    NfcTagStore.clearAll()

                    result.success(null)
                }

                // ========================================================
                // HCE
                // ========================================================

                "startEmulator" -> {

                    Log.d(
                        TAG,
                        "START EMULATOR REQUEST"
                    )

                    // Android automatically manages HCE.
                    result.success(null)
                }

                "stopEmulator" -> {

                    Log.d(
                        TAG,
                        "STOP EMULATOR REQUEST"
                    )

                    // Android automatically manages HCE.
                    result.success(null)
                }

                // ========================================================
                // READER
                // ========================================================

                "startReader" -> {

                    startReader()

                    result.success(null)
                }

                "stopReader" -> {

                    stopReader()

                    result.success(null)
                }

                // ========================================================
                // UNKNOWN
                // ========================================================

                else -> {

                    result.notImplemented()
                }
            }
        }
    }

    // ================================================================
    // START READER
    // ================================================================

    private fun startReader() {

        val adapter =
            nfcAdapter

        if (adapter == null) {

            Log.e(
                TAG,
                "NFC ADAPTER NOT AVAILABLE"
            )

            return
        }

        Log.d(
            TAG,
            "STARTING NFC READER"
        )

        adapter.enableReaderMode(
            this,
            { tag ->
                handleTag(tag)
            },
            NfcAdapter.FLAG_READER_NFC_A or
                    NfcAdapter.FLAG_READER_SKIP_NDEF_CHECK,
            null
        )
    }

    // ================================================================
    // STOP READER
    // ================================================================

    private fun stopReader() {

        Log.d(
            TAG,
            "STOPPING NFC READER"
        )

        nfcAdapter
            ?.disableReaderMode(
                this
            )
    }

    // ================================================================
    // TAG DISCOVERED
    // ================================================================

    private fun handleTag(
        tag: Tag
    ) {

        Log.d(
            TAG,
            "TAG DISCOVERED"
        )

        val isoDep =
            IsoDep.get(tag)

        if (isoDep == null) {

            Log.e(
                TAG,
                "TAG DOES NOT SUPPORT ISO-DEP"
            )

            return
        }

        try {

            isoDep.connect()

            Log.d(
                TAG,
                "ISO-DEP CONNECTED"
            )

            // ========================================================
            // SELECT AID
            // ========================================================

            val selectApdu = byteArrayOf(
                0x00,
                0xA4.toByte(),
                0x04,
                0x00,
                0x06,
                0xF0.toByte(),
                0x01,
                0x02,
                0x03,
                0x04,
                0x05,
                0x00
            )

            Log.d(
                TAG,
                "SENDING SELECT"
            )

            val selectResponse =
                isoDep.transceive(
                    selectApdu
                )

            Log.d(
                TAG,
                "SELECT RESPONSE: " +
                        selectResponse.toHex()
            )

            if (
                !selectResponse.endsWithStatus(
                    0x90,
                    0x00
                )
            ) {

                Log.e(
                    TAG,
                    "SELECT FAILED"
                )

                return
            }

            // ========================================================
            // REQUEST SESSION UUID
            // ========================================================

            val sessionUuid =
                requestTag(
                    isoDep,
                    TAG_SESSION_UUID
                )

            if (sessionUuid != null) {

                Log.d(
                    TAG,
                    "SESSION UUID: $sessionUuid"
                )

                sendFlutterMessage(
                    "sessionUuid",
                    sessionUuid
                )
            }

            // ========================================================
            // REQUEST PLAYER INFO
            // ========================================================

            val playerInfo =
                requestTag(
                    isoDep,
                    TAG_PLAYER_INFO
                )

            if (playerInfo != null) {

                Log.d(
                    TAG,
                    "PLAYER INFO: $playerInfo"
                )

                sendFlutterMessage(
                    "playerInfo",
                    playerInfo
                )
            }

        } catch (e: Exception) {

            Log.e(
                TAG,
                "NFC ERROR",
                e
            )

        } finally {

            try {
                isoDep.close()
            } catch (_: Exception) {
            }
        }
    }

    // ================================================================
    // REQUEST TAG
    // ================================================================

    private fun requestTag(
        isoDep: IsoDep,
        tagType: Int
    ): String? {

        val apdu = byteArrayOf(
            0x80.toByte(),
            0xCA.toByte(),
            tagType.toByte(),
            0x00,
            0x00
        )

        Log.d(
            TAG,
            "REQUESTING TAG: " +
                    tagType.toHexByte()
        )

        val response =
            isoDep.transceive(
                apdu
            )

        Log.d(
            TAG,
            "TAG RESPONSE: " +
                    response.toHex()
        )

        if (
            !response.endsWithStatus(
                0x90,
                0x00
            )
        ) {

            Log.e(
                TAG,
                "TAG REQUEST FAILED"
            )

            return null
        }

        return response
            .copyOfRange(
                0,
                response.size - 2
            )
            .toString(
                Charsets.UTF_8
            )
    }

    // ================================================================
    // SEND MESSAGE TO FLUTTER
    // ================================================================

    private fun sendFlutterMessage(
        type: String,
        json: String
    ) {

        runOnUiThread {

            methodChannel?.invokeMethod(
                "nfcMessage",
                mapOf(
                    "type" to type,
                    "json" to json
                )
            )
        }
    }

    // ================================================================
    // DESTROY
    // ================================================================

    override fun onDestroy() {

        stopReader()

        super.onDestroy()
    }

    // ================================================================
    // BYTE HELPERS
    // ================================================================

    private fun ByteArray.toHex(): String {

        return joinToString(" ") {
            "%02X".format(
                it.toInt() and 0xFF
            )
        }
    }

    private fun Int.toHexByte(): String {

        return "%02X".format(
            this and 0xFF
        )
    }

    private fun ByteArray.endsWithStatus(
        sw1: Int,
        sw2: Int
    ): Boolean {

        if (size < 2) {
            return false
        }

        return (
                this[size - 2].toInt()
                        and 0xFF
                ) == sw1 &&
                (
                        this[size - 1].toInt()
                                and 0xFF
                        ) == sw2
    }
}