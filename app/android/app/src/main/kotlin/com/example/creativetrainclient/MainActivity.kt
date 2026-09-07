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

        private const val TAG_SESSION_UUID = 0x01
        private const val TAG_PLAYER_INFO = 0x02
    }

    private var methodChannel: MethodChannel? = null
    private var nfcAdapter: NfcAdapter? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        nfcAdapter = NfcAdapter.getDefaultAdapter(this)

        Log.d(TAG, "MAIN ACTIVITY CREATED")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Log.d(TAG, "REGISTERING METHOD CHANNEL: $CHANNEL")

        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )

        methodChannel?.setMethodCallHandler { call, result ->

            Log.d(TAG, "METHOD CALLED: ${call.method}")

            when (call.method) {

                "setSessionUuid" -> {

                    val sessionUuid =
                        call.argument<String>("sessionUuid")

                    if (sessionUuid == null) {
                        result.error(
                            "INVALID_ARGUMENT",
                            "sessionUuid is required",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    Log.d(TAG, "SETTING sessionUuid TAG")

                    NfcTagStore.setSessionUuid(sessionUuid)

                    result.success(null)
                }

                "clearSessionUuid" -> {

                    Log.d(TAG, "CLEARING sessionUuid TAG")

                    NfcTagStore.clearSessionUuid()

                    result.success(null)
                }

                "setPlayerInfo" -> {

                    val playerUuid =
                        call.argument<String>("playerUuid")

                    val challenge =
                        call.argument<String>("challenge")

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

                    Log.d(TAG, "SETTING playerInfo TAG")

                    NfcTagStore.setPlayerInfo(
                        playerUuid,
                        challenge
                    )

                    result.success(null)
                }

                "clearPlayerInfo" -> {

                    Log.d(TAG, "CLEARING playerInfo TAG")

                    NfcTagStore.clearPlayerInfo()

                    result.success(null)
                }

                "clearTags" -> {

                    Log.d(TAG, "CLEARING ALL NFC TAGS")

                    NfcTagStore.clearAll()

                    result.success(null)
                }

                "startEmulator" -> {

                    Log.d(TAG, "START EMULATOR REQUEST")

                    result.success(null)
                }

                "stopEmulator" -> {

                    Log.d(TAG, "STOP EMULATOR REQUEST")

                    result.success(null)
                }

                "startReader" -> {
                    readerTagType =
                        call.argument<Int>("tagType") ?: 1

                    Log.d(
                        "NFC_READER",
                        "START READER - TAG TYPE: $readerTagType"
                    )

                    startReader()
                    result.success(null)
                }

                "stopReader" -> {

                    stopReader()

                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun startReader() {

        val adapter = nfcAdapter

        if (adapter == null) {
            Log.e(TAG, "NFC ADAPTER NOT AVAILABLE")
            return
        }

        Log.d(TAG, "STARTING NFC READER")

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

    private fun stopReader() {

        Log.d(TAG, "STOPPING NFC READER")

        nfcAdapter?.disableReaderMode(this)
    }
    private fun handleTag(tag: Tag) {
        Log.d("NFC_READER", "TAG DISCOVERED")

        val isoDep = IsoDep.get(tag)

        if (isoDep == null) {
            Log.e("NFC_READER", "ISO-DEP NOT AVAILABLE")
            return
        }

        try {
            isoDep.connect()

            Log.d("NFC_READER", "ISO-DEP CONNECTED")

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

            Log.d("NFC_READER", "SENDING SELECT")

            val selectResponse = isoDep.transceive(selectApdu)

            Log.d(
                "NFC_READER",
                "SELECT RESPONSE: ${selectResponse.toHex()}"
            )

            if (!selectResponse.endsWithStatus(0x90, 0x00)) {
                Log.e(
                    "NFC_READER",
                    "SELECT FAILED"
                )
                return
            }

            Log.d(
                "NFC_READER",
                "REQUESTING TAG: %02d".format(readerTagType)
            )

            val json = requestTag(
                isoDep,
                readerTagType
            )

            if (json == null) {
                Log.e(
                    "NFC_READER",
                    "TAG REQUEST FAILED"
                )
                return
            }

            when (readerTagType) {
                1 -> {
                    Log.d(
                        "NFC_READER",
                        "SESSION UUID: $json"
                    )

                    sendFlutterMessage(
                        "sessionUuid",
                        json
                    )
                }

                2 -> {
                    Log.d(
                        "NFC_READER",
                        "PLAYER INFO: $json"
                    )

                    sendFlutterMessage(
                        "playerInfo",
                        json
                    )
                }

                else -> {
                    Log.e(
                        "NFC_READER",
                        "UNKNOWN READER TAG TYPE: $readerTagType"
                    )
                }
            }

        } catch (e: Exception) {
            Log.e(
                "NFC_READER",
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
            isoDep.transceive(apdu)

        Log.d(
            TAG,
            "TAG RESPONSE: " +
                    response.toHex()
        )

        if (!response.endsWithStatus(0x90, 0x00)) {

            Log.e(TAG, "TAG REQUEST FAILED")

            return null
        }

        return response
            .copyOfRange(
                0,
                response.size - 2
            )
            .toString(Charsets.UTF_8)
    }

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

    override fun onDestroy() {

        stopReader()

        super.onDestroy()
    }

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

        if (size < 2) return false

        return (
                this[size - 2].toInt() and 0xFF
                ) == sw1 &&
                (
                        this[size - 1].toInt() and 0xFF
                        ) == sw2
    }
}