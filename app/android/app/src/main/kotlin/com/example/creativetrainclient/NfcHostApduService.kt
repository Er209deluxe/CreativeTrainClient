package com.example.creativetrainclient

import android.nfc.cardemulation.HostApduService
import android.os.Bundle
import android.util.Log
import java.nio.charset.StandardCharsets

class NfcHostApduService : HostApduService() {

    companion object {
        private const val TAG = "NFC_HCE"

        private val AID = byteArrayOf(
            0xF0.toByte(),
            0x01,
            0x02,
            0x03,
            0x04,
            0x05
        )

        private const val TAG_SESSION_UUID = 0x01
        private const val TAG_PLAYER_INFO = 0x02

        private val SW_OK = byteArrayOf(
            0x90.toByte(),
            0x00
        )

        private val SW_UNKNOWN = byteArrayOf(
            0x6D,
            0x00
        )
    }

    override fun processCommandApdu(
        commandApdu: ByteArray,
        extras: Bundle?
    ): ByteArray {

        Log.d(
            TAG,
            "APDU RECEIVED: ${commandApdu.toHex()}"
        )

        if (isSelectAid(commandApdu)) {

            Log.d(
                TAG,
                "SELECT AID RECEIVED"
            )

            return byteArrayOf(
                0x48,
                0x45,
                0x4C,
                0x4C,
                0x4F,
                0x90.toByte(),
                0x00
            )
        }

        // GET NFC PEER DATA
        if (
            commandApdu.size >= 5 &&
            commandApdu[0] == 0x80.toByte() &&
            commandApdu[1] == 0xCA.toByte() &&
            commandApdu[2] == 0x00.toByte()
        ) {
            // Pass 'this' as the context
            val json = NfcTagStore.getJson(this)

            Log.d(TAG, "NFC PEER DATA: $json")

            return json.toByteArray(Charsets.UTF_8) +
                    byteArrayOf(0x90.toByte(), 0x00)
        }

        Log.w(
            TAG,
            "UNKNOWN APDU"
        )

        return byteArrayOf(
            0x6D.toByte(),
            0x00
        )
    }

    private fun isSelectAid(commandApdu: ByteArray): Boolean {

        if (commandApdu.size < 12) {
            return false
        }

        if (commandApdu[0] != 0x00.toByte()) return false
        if (commandApdu[1] != 0xA4.toByte()) return false
        if (commandApdu[2] != 0x04.toByte()) return false
        if (commandApdu[3] != 0x00.toByte()) return false
        if (commandApdu[4] != 0x06.toByte()) return false

        for (i in AID.indices) {
            if (commandApdu[5 + i] != AID[i]) {
                return false
            }
        }

        return true
    }

    override fun onDeactivated(reason: Int) {
        Log.d(TAG, "HCE DEACTIVATED: $reason")
    }

    private fun ByteArray.toHex(): String {
        return joinToString(" ") {
            "%02X".format(it.toInt() and 0xFF)
        }
    }
}