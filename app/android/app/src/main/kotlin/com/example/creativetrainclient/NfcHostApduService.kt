package com.example.creativetrainclient

import android.nfc.cardemulation.HostApduService
import android.os.Bundle
import android.util.Log

class NfcHostApduService : HostApduService() {

    companion object {

        private const val TAG = "NFC_HCE"

        const val AID = "F00102030405"

        // APDU response status
        private val SUCCESS = byteArrayOf(
            0x90.toByte(),
            0x00
        )

        private val UNKNOWN_COMMAND = byteArrayOf(
            0x6D.toByte(),
            0x00
        )

        // ============================================================
        // TAG IDS
        // ============================================================

        private const val TAG_SESSION_UUID = 0x01
        private const val TAG_PLAYER_INFO = 0x02
    }

    override fun onCreate() {
        super.onCreate()

        Log.d(
            TAG,
            "HCE SERVICE CREATED"
        )
    }

    // ================================================================
    // APDU HANDLER
    // ================================================================

    override fun processCommandApdu(
        commandApdu: ByteArray,
        extras: Bundle?
    ): ByteArray {

        val apduHex =
            commandApdu.joinToString(" ") {
                "%02X".format(
                    it.toInt() and 0xFF
                )
            }

        Log.d(
            TAG,
            "APDU RECEIVED: $apduHex"
        )

        // ============================================================
        // SELECT AID
        // ============================================================

        if (isSelectAid(commandApdu)) {

            Log.d(
                TAG,
                "SELECT AID RECEIVED"
            )

            return SUCCESS
        }

        // ============================================================
        // GET TAG
        // ============================================================

        if (isGetData(commandApdu)) {

            val tagType =
                commandApdu[2].toInt() and 0xFF

            return when (tagType) {

                // ----------------------------------------------------
                // SESSION UUID
                // ----------------------------------------------------

                TAG_SESSION_UUID -> {

                    Log.d(
                        TAG,
                        "REQUEST: sessionUuid"
                    )

                    val json =
                        NfcTagStore
                            .getSessionUuidJson()

                    if (json == null) {

                        Log.d(
                            TAG,
                            "sessionUuid TAG NOT SET"
                        )

                        UNKNOWN_COMMAND

                    } else {

                        Log.d(
                            TAG,
                            "RESPONDING WITH: $json"
                        )

                        respondWithJson(json)
                    }
                }

                // ----------------------------------------------------
                // PLAYER INFO
                // ----------------------------------------------------

                TAG_PLAYER_INFO -> {

                    Log.d(
                        TAG,
                        "REQUEST: playerInfo"
                    )

                    val json =
                        NfcTagStore
                            .getPlayerInfoJson()

                    if (json == null) {

                        Log.d(
                            TAG,
                            "playerInfo TAG NOT SET"
                        )

                        UNKNOWN_COMMAND

                    } else {

                        Log.d(
                            TAG,
                            "RESPONDING WITH: $json"
                        )

                        respondWithJson(json)
                    }
                }

                // ----------------------------------------------------
                // UNKNOWN TAG
                // ----------------------------------------------------

                else -> {

                    Log.d(
                        TAG,
                        "UNKNOWN TAG TYPE: $tagType"
                    )

                    UNKNOWN_COMMAND
                }
            }
        }

        // ============================================================
        // UNKNOWN APDU
        // ============================================================

        Log.d(
            TAG,
            "UNKNOWN APDU"
        )

        return UNKNOWN_COMMAND
    }

    // ================================================================
    // SELECT AID
    // ================================================================

    private fun isSelectAid(
        apdu: ByteArray
    ): Boolean {

        if (apdu.size < 11) {
            return false
        }

        if (apdu[0] != 0x00.toByte()) {
            return false
        }

        if (apdu[1] != 0xA4.toByte()) {
            return false
        }

        if (apdu[2] != 0x04.toByte()) {
            return false
        }

        if (apdu[3] != 0x00.toByte()) {
            return false
        }

        if (apdu[4] != 0x06.toByte()) {
            return false
        }

        val expectedAid = byteArrayOf(
            0xF0.toByte(),
            0x01,
            0x02,
            0x03,
            0x04,
            0x05
        )

        for (i in expectedAid.indices) {

            if (
                apdu[5 + i] !=
                expectedAid[i]
            ) {
                return false
            }
        }

        return true
    }

    // ================================================================
    // GET DATA
    // ================================================================

    private fun isGetData(
        apdu: ByteArray
    ): Boolean {

        return apdu.size >= 5 &&
                apdu[0] == 0x80.toByte() &&
                apdu[1] == 0xCA.toByte()
    }

    // ================================================================
    // JSON RESPONSE
    // ================================================================

    private fun respondWithJson(
        json: String
    ): ByteArray {

        val jsonBytes =
            json.toByteArray(
                Charsets.UTF_8
            )

        return jsonBytes + SUCCESS
    }

    // ================================================================
    // NFC DEACTIVATED
    // ================================================================

    override fun onDeactivated(
        reason: Int
    ) {

        Log.d(
            TAG,
            "NFC DEACTIVATED: $reason"
        )
    }
}