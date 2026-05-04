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
let eventSource;

function startStream(playerUuid) {
const url = `/api/stream?playerUuid=${playerUuid}&ts=${Date.now()}`;
    const eventSource = new EventSource(url);
    
    // Assuming `eventSource` is initialized as shown previously
eventSource.onmessage = (event) => {
    console.log("Stream message:", event.data);  // Log the raw message
    const eventData = event.data;

    if (eventData.includes('playerJoined')) {
        console.log("New player joined:", eventData);
        // Parse or handle the event data
        const playerName = eventData.split('|')[1];  // Assuming the format is playerJoined|playerName
        alert(`${playerName} has joined the session!`);
    }
};

    eventSource.onerror = () => {
        console.log("Stream disconnected");
    };
}
async function registerAndConnect() {
    const result = await registerUser();

    // Parse the response data into JSON
    const data = JSON.parse(result.data);  // Parse the string to JSON

    const playerUuid = data.playerUuid; // Access the playerUuid property

    startStream(playerUuid);
}
async function registerUser() {
    const isHost = document.getElementById("isHost").checked;
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
    if(!isHost && !joinedSession) {
        alert("Please enter the session ID you want to join.");
        return;
    }
    // Create a FormData object to send both file and other fields
    const formData = new FormData();
    formData.append("playerQr", file); // Append the file as 'playerQr'
    formData.append("playerName", playerName);
    if(!isHost) {
        formData.append("joinedSession", joinedSession);
    }

    // Make the POST request with FormData
    const response = await fetch("/api/session/register", {
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