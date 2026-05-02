async function makePostRequest(url, method, data = null) {
    const response = await fetch(url, {
        method,
        headers: data ? { "Content-Type": "application/json" } : {},
        body: data ? JSON.stringify(data) : null
    });

    const text = await response.text();

    return {
        status: response.status,
        ok: response.ok,
        body: text
    };
}

async function makeGetRequest(url) {
    const response = await fetch(url);
    const text = await response.text();

    return {
        status: response.status,
        ok: response.ok,
        body: text
    };
}

// ---------------- QR ----------------
async function generatePlayerQr() {
    document.getElementById("qrCode").src =
        "/api/newPlayerQr?ts=" + Date.now(); // cache-bust
}

// ---------------- START SESSION ----------------
async function startSession() {
    const sessionId = document.getElementById("start-session-uuid").value;
    const hostUuid = document.getElementById("host-uuid").value;

    const res = await makePostRequest("/api/session/start", "POST", {
        sessionId,
        hostUuid
    });

    console.log("Start session:", res);
    return res;
}

// ---------------- REGISTER USER ----------------
async function registerUser() {
    const playerUuidInput = document.getElementById("player-uuid");
    const playerName = document.getElementById("player-name").value;
    const joinedSession = document.getElementById("register-session-uuid").value;
    const file = playerUuidInput.files[0]; // Get the file from the input

    // Check if a file has been selected
    if (!file) {
        alert("Please select a file to upload.");
        return;
    }
    if (!playerName) {
        alert("Please enter your username.");
        return;
    }

    // Create a FormData object to send both file and other fields
    const formData = new FormData();
    formData.append("playerQr", file); // Append the file as 'playerQr'
    formData.append("playerName", playerName);
    formData.append("joinedSession", joinedSession); // Optional, if provided

    // Make the POST request with FormData
    const response = await fetch("/api/session/registerUser", {
        method: "POST",
        body: formData // Note: FormData automatically sets the correct Content-Type
    });

    const text = await response.text();
    console.log("Response:", text);

    return {
        status: response.status,
        ok: response.ok,
        data: text
    };
}