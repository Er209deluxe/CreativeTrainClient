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
    }

    private var methodChannel: MethodChannel? = null

    private var nfcAdapter: NfcAdapter? = null

    override fun onCreate(
        savedInstanceState: Bundle?
    ) {
        super.onCreate(savedInstanceState)

        nfcAdapter =
            NfcAdapter.getDefaultAdapter(this)

        Log.d(
            TAG,
            "MAIN ACTIVITY CREATED"
        )

        Log.d(
            TAG,
            "NFC HARDWARE AVAILABLE: " +
                    (nfcAdapter != null)
        )

        Log.d(
            TAG,
            "NFC ENABLED: " +
                    (nfcAdapter?.isEnabled == true)
        )
    }

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

                /*
                 * Check whether the device:
                 *
                 * 1. has NFC hardware
                 * 2. has NFC enabled
                 *
                 * Returns true only when both
                 * conditions are satisfied.
                 */
                "isNfcAvailable" -> {

                    val adapter =
                        nfcAdapter

                    val available =
                        adapter != null

                    val enabled =
                        adapter?.isEnabled == true

                    Log.d(
                        TAG,
                        "NFC AVAILABLE: $available"
                    )

                    Log.d(
                        TAG,
                        "NFC ENABLED: $enabled"
                    )

                    result.success(
                        available && enabled
                    )
                }

                "setSessionUuid" -> {
                    val sessionUuid = call.argument<String>("sessionUuid")
                    // Add 'this,' as the first argument
                    NfcTagStore.setSessionUuid(this, sessionUuid)
                    result.success(null)
                }

                "setPlayerUuid" -> {
                    val playerUuid = call.argument<String>("playerUuid")
                    // Add 'this,' as the first argument
                    NfcTagStore.setPlayerUuid(this, playerUuid)
                    result.success(null)
                }

                "setChallenge" -> {
                    val challenge = call.argument<String>("challenge")
                    // Add 'this,' as the first argument
                    NfcTagStore.setChallenge(this, challenge)
                    result.success(null)
                }

                "clearTags" -> {
                    Log.d(TAG, "CLEARING ALL NFC DATA")
                    // Add 'this' as the argument
                    NfcTagStore.clear(this)
                    result.success(null)
                }
                /*
                 * HCE emulator is now controlled
                 * by the Android OS.
                 *
                 * These methods are retained so
                 * existing Flutter code does not
                 * break.
                 */
                "startEmulator" -> {

                    Log.d(
                        TAG,
                        "START EMULATOR REQUEST"
                    )

                    result.success(null)
                }

                "stopEmulator" -> {

                    Log.d(
                        TAG,
                        "STOP EMULATOR REQUEST"
                    )

                    result.success(null)
                }

                /*
                 * Start NFC Reader Mode
                 */
                "startReader" -> {

                    Log.d(
                        TAG,
                        "START READER REQUEST"
                    )

                    startReader()

                    result.success(null)
                }

                /*
                 * Stop NFC Reader Mode
                 */
                "stopReader" -> {

                    Log.d(
                        TAG,
                        "STOP READER REQUEST"
                    )

                    stopReader()

                    result.success(null)
                }

                else -> {

                    Log.w(
                        TAG,
                        "UNKNOWN METHOD: " +
                                call.method
                    )

                    result.notImplemented()
                }
            }
        }
    }

    /*
     * --------------------------------------------------
     * NFC READER
     * --------------------------------------------------
     */

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

        if (!adapter.isEnabled) {

            Log.e(
                TAG,
                "NFC IS DISABLED"
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
                    NfcAdapter
                        .FLAG_READER_SKIP_NDEF_CHECK,

            null
        )

        Log.d(
            TAG,
            "NFC READER STARTED"
        )
    }

    private fun stopReader() {

        Log.d(
            TAG,
            "STOPPING NFC READER"
        )

        nfcAdapter?.disableReaderMode(
            this
        )

        Log.d(
            TAG,
            "NFC READER STOPPED"
        )
    }

    /*
     * --------------------------------------------------
     * HANDLE DISCOVERED NFC DEVICE
     * --------------------------------------------------
     */

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
                "ISO-DEP NOT AVAILABLE"
            )

            return
        }

        try {

            isoDep.connect()

            // ---> FIX ADDED HERE <---
            // Increase timeout to 5 seconds to prevent TagLostException
            // caused by slow HCE response times between two phones.
            isoDep.timeout = 5000

            Log.d(
                TAG,
                "ISO-DEP CONNECTED (Timeout set to 5000ms)"
            )

            /*
             * SELECT HCE AID
             *
             * AID:
             * F0 01 02 03 04 05
             */
            val selectApdu =
                byteArrayOf(

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

            Log.d(
                TAG,
                "SELECT APDU: " +
                        selectApdu.toHex()
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

            Log.d(
                TAG,
                "SELECT SUCCESSFUL"
            )

            /*
             * Request the complete NFC object.
             *
             * APDU:
             *
             * 80 CA 00 00 00
             */
            val json =
                requestPeerData(
                    isoDep
                )

            if (json == null) {

                Log.e(
                    TAG,
                    "NFC DATA REQUEST FAILED"
                )

                return
            }

            Log.d(
                TAG,
                "NFC PEER DATA: $json"
            )

            /*
             * Send complete object to Flutter.
             */
            sendFlutterMessage(
                "nfcPeer",
                json
            )

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

            Log.d(
                TAG,
                "ISO-DEP CLOSED"
            )
        }
    }

    /*
     * --------------------------------------------------
     * REQUEST COMPLETE NFC OBJECT
     * --------------------------------------------------
     */

    private fun requestPeerData(
        isoDep: IsoDep
    ): String? {

        /*
         * GET DATA
         *
         * 80 CA 00 00 00
         */
        val apdu =
            byteArrayOf(

                0x80.toByte(),

                0xCA.toByte(),

                0x00,

                0x00,

                0x00
            )

        Log.d(
            TAG,
            "REQUESTING NFC PEER DATA"
        )

        Log.d(
            TAG,
            "APDU: ${apdu.toHex()}"
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

        /*
         * Need at least SW1 + SW2.
         */
        if (response.size < 2) {

            Log.e(
                TAG,
                "NFC RESPONSE TOO SHORT"
            )

            return null
        }

        /*
         * Extract status word.
         */
        val sw1 =
            response[
                response.size - 2
            ].toInt() and 0xFF

        val sw2 =
            response[
                response.size - 1
            ].toInt() and 0xFF

        Log.d(
            TAG,
            "STATUS WORD: %02X %02X"
                .format(
                    sw1,
                    sw2
                )
        )

        /*
         * Require 90 00.
         */
        if (
            sw1 != 0x90 ||
            sw2 != 0x00
        ) {

            Log.e(
                TAG,
                "NFC DATA REQUEST FAILED: " +
                        "%02X %02X"
                            .format(
                                sw1,
                                sw2
                            )
            )

            return null
        }

        /*
         * Remove SW1 + SW2.
         */
        val data =
            response.copyOfRange(
                0,
                response.size - 2
            )

        /*
         * Convert JSON bytes to String.
         */
        val json =
            data.toString(
                Charsets.UTF_8
            )

        Log.d(
            TAG,
            "NFC JSON: $json"
        )

        return json
    }

    /*
     * --------------------------------------------------
     * SEND NFC DATA TO FLUTTER
     * --------------------------------------------------
     */

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

    /*
     * --------------------------------------------------
     * ACTIVITY LIFECYCLE
     * --------------------------------------------------
     */

    override fun onDestroy() {

        Log.d(
            TAG,
            "MAIN ACTIVITY DESTROYED"
        )

        stopReader()

        methodChannel = null

        super.onDestroy()
    }

    /*
     * --------------------------------------------------
     * BYTE ARRAY HELPERS
     * --------------------------------------------------
     */

    private fun ByteArray.toHex(): String {

        return joinToString(" ") {

            "%02X".format(
                it.toInt() and 0xFF
            )
        }
    }

    private fun ByteArray.endsWithStatus(
        sw1: Int,
        sw2: Int
    ): Boolean {

        if (size < 2) {
            return false
        }

        return (
                this[size - 2]
                    .toInt() and 0xFF
                ) == sw1 &&
                (
                        this[size - 1]
                            .toInt() and 0xFF
                        ) == sw2
    }
}