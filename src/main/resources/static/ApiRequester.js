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
    const sessionId = sessionStorage.getItem("sessionUuid");
    const hostUuid = sessionStorage.getItem("playerUuid");

    const res = await makePostRequest("/api/session/start", "POST", {
        sessionId,
        hostUuid
    });
    if(res.status == 404) {
        alert("Session not found");
        return;
    } else if(res.status == 403) {
        alert("Only the host can start the session");
        return;
    }
    else if(!res.ok) {
        alert("Failed to start session: " + res.body);
        return;
    }

    console.log("Start session:", res);
    return res;
}
async function leaveSession() {
     const playerUuid = sessionStorage.getItem("playerUuid");
    if (!playerUuid) return;

    const url = `/api/session/leaveGame?playerUuid=${playerUuid}`;

    navigator.sendBeacon(url);

    stopStream();
    sessionStorage.clear();

    console.log("left session " + playerUuid);
}
let eventSource;
const userElements = new Map();

function startStream(playerUuid) {
    const url = `/api/stream?playerUuid=${playerUuid}&ts=${Date.now()}`;
    const eventSource = new EventSource(url);

    // ✅ ADD USER
    eventSource.addEventListener("playerJoined", (event) => {
        console.log("New player joined:", event.data);

        const container = document.getElementById("currentUsers");

        const p = document.createElement("p");
        p.textContent = event.data;
        container.appendChild(p);

        // store reference so we can remove later
        userElements.set(event.data, p);
    });

    // ❌ REMOVE USER
    eventSource.addEventListener("playerDisconnected", (event) => {
        console.log("Player disconnected:", event.data);

        const element = userElements.get(event.data);

        if (element) {
            element.remove(); // removes from DOM
            userElements.delete(event.data);
        }
    });

    eventSource.onerror = () => {
        console.log("Stream disconnected");
    };
}
async function registerAndConnect() {
    if(sessionStorage.getItem("playerUuid") || sessionStorage.getItem("sessionUuid")) {
        return; //already registered
    }
    const result = await registerUser();

    // Parse the response data into JSON
    const data = JSON.parse(result.data);  // Parse the string to JSON

    const playerUuid = data.playerUuid; // Access the playerUuid property
    const sessionUuid = data.sessionId; // Access the sessionUuid property
    sessionStorage.setItem("playerUuid", playerUuid)
    sessionStorage.setItem("sessionUuid",sessionUuid)

    console.log("loginResponse", `sessionStorage set with token value: ${playerUuid}`)
    startStream(playerUuid);
    //const sessionUuid= document.getElementById("register-session-uuid").value;
    if (sessionUuid && sessionUuid.length > 0) {
                await getCurrentUsers({  sessionUuid});

    }
}
window.addEventListener("beforeunload", () => {
    leaveSession();
});
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
async function makeUserRequest(params){
    const getHostUrl = `/api/session/hostName?${new URLSearchParams(params).toString()}`;
    const url = `/api/session/connectedUsers?${new URLSearchParams(params).toString()}`;

    const [response, hostResponse] = await Promise.all([
        makeGetRequest(url),
        makeGetRequest(getHostUrl)
    ]);

    return { response, hostResponse };
}

async function getCurrentUsers(params) {
    //const response = await makeGetRequest(url);
    const { response, hostResponse } = await makeUserRequest(params);
    const container = document.getElementById("currentUsers");
    //p.style.color = "green"; // optional: highlight new joiners
    //const hostResponse = await makeGetRequest(getHostUrl);
    // optional but recommended: prevent duplicates
    container.innerHTML = "";

    let users;

    try {
        users = JSON.parse(response.body);
    } catch (e) {
        console.error("Failed to parse users:", response.body);
        return response;
    }
   
    
    // If backend sends a Set serialized as array -> fine
    // If it's an object, convert accordingly
    if (Array.isArray(users)) {
        users.forEach(name => {
            const p = document.createElement("p");
            p.textContent = name;
            if(name === hostResponse.body) {
                p.style.color = "green";
            }
            container.appendChild(p);
        });
    } else if (users && typeof users === "object") {
        // fallback for weird JSON shapes (like {"user1":true})
        Object.keys(users).forEach(name => {
            const p = document.createElement("p");
            p.textContent = name;
            container.appendChild(p);
        });
    } else {
        console.warn("Unexpected users format:", users);
    }

    return response;
}
function stopStream() {
    if (eventSource) {
        eventSource.close();
        console.log("Stream stopped");
    }
}