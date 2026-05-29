async function makePostRequest(url, method, data = null) {

    const response = await fetch(url, {
        method,
        headers: data
            ? { "Content-Type": "application/json" }
            : {},
        body: data
            ? JSON.stringify(data)
            : null
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

/* ---------------- QR ---------------- */

async function generatePlayerQr() {

    document.getElementById("qrCode").src =
        "/api/newPlayerQr?ts=" + Date.now();
}

/* ---------------- SESSION ---------------- */

async function startSession() {

    const sessionId =
        sessionStorage.getItem("sessionUuid");

    const playerUuid =
        sessionStorage.getItem("playerUuid");

    const roleConfig =
        encodeURIComponent(uploadedRoleConfig || "");

    const res = await makePostRequest(
        "/api/session/start" +
        "?sessionToken=" +
        sessionStorage.getItem("sessionToken") +
        "&RoleConfig=" +
        roleConfig +
        "&ts=" +
        Date.now(),
        "POST",
        {
            sessionId,
            playerUuid
        }
    );

    console.log(res);

    if (!res.ok) {
        alert("Failed to start session: " + res.body);
        return;
    }

    console.log("Session started");
}

/* ---------------- STREAM ---------------- */

let eventSource = null;

const userElements = new Map();

function startStream(playerUuid) {

    stopStream();

    const url =
        `/api/stream?playerUuid=${playerUuid}&sessionToken=${sessionStorage.getItem("sessionToken")}&ts=${Date.now()}`;

    eventSource = new EventSource(url);

    
    eventSource.onerror = async (err) => {

        console.log("SSE error", err);

        try {

            const response = await fetch(url, {
                method: "GET"
            });

            if (response.status === 404) {
                console.log("Player not found");
            }
            else if (response.status === 403) {
                console.log("Forbidden");
            }
            else {
                console.log("Unknown SSE error");
            }

        } catch (e) {
            console.error("Network error", e);
        }

        window.location.href="/";

        eventSource.close();
    };

    const userList =
        document.getElementById("userList");

    eventSource.addEventListener(
        "playerJoined",
        (event) => {

            const name = event.data;

            console.log("Joined:", name);

            if (userElements.has(name)) {
                return;
            }

            const li = document.createElement("li");

            li.textContent = name;

            userList.appendChild(li);

            userElements.set(name, li);
        }
    );

    eventSource.addEventListener(
        "playerDisconnected",
        (event) => {

            const name = event.data;

            console.log("Disconnected:", name);

            const element =
                userElements.get(name);

            if (element) {
                element.remove();
                userElements.delete(name);
            }
        }
    );

    eventSource.addEventListener(
        "sessionStart",
        (event) => {

            const role = JSON.parse(event.data);

            showTransition(
                `Session Started! Role: ${role.name}`,
                role.hex
            );

            setTimeout(() => {

                shouldLeaveSession = false;

                window.location.href =
                    "activeGame?sessionUuid=" +
                    sessionStorage.getItem("sessionUuid");

                hideTransition();

            }, 10000);
        }
    );

    eventSource.onerror = () => {
        console.log("Stream disconnected");
    };
}

function showTransition(
    text = "Loading...",
    color = "#fff"
) {

    const screen =
        document.getElementById("transitionScreen");

    screen.textContent = text;
    screen.style.color = color;

    screen.classList.add("active");
}

function hideTransition() {

    const screen =
        document.getElementById("transitionScreen");

    screen.classList.remove("active");
}

function stopStream() {

    if (eventSource) {

        eventSource.close();

        eventSource = null;

        console.log("Stream stopped");
    }
}

/* ---------------- REGISTER ---------------- */
async function registerAndConnect() {

    if (
        sessionStorage.getItem("playerUuid") ||
        sessionStorage.getItem("sessionUuid")
    ) {

        alert(
            "Already registered in a session."
        );

        return;
    }

    // Save host state at registration time
    const isHost =
        document.getElementById("isHost").checked;

    const result = await registerUser();

    if (!result || !result.ok) {

        alert(
            "Registration failed: " +
            (result ? result.data : "Unknown error")
        );
        
        return;
    }

    let data;

    try {

        data = JSON.parse(result.data);

    } catch (err) {

        console.error(
            "Invalid JSON:",
            result.data
        );

        return;
    }

    const playerUuid =
        data.playerUuid;

    const sessionUuid =
        data.sessionId;

    const sessionToken =
        data.sessionToken;

    sessionStorage.setItem(
        "playerUuid",
        playerUuid
    );

    sessionStorage.setItem(
        "sessionUuid",
        sessionUuid
    );

    sessionStorage.setItem(
        "sessionToken",
        sessionToken
    );

    document.getElementById(
        "sessionUuidDisplay"
    ).innerText = sessionUuid;

    // Hide registration UI after successful register
    document.getElementById(
        "registrationSection"
    ).style.display = "none";

    // If user registered as host,
    // show host controls permanently
    if (isHost) {

        document.getElementById(
            "hostConfigSection"
        ).style.display = "block";

        document.getElementById(
            "startSessionButton"
        ).style.display = "block";
    }

    console.log("Connected:", playerUuid);

    startStream(playerUuid);

    await getCurrentUsers({
        sessionUuid
    });
}

async function registerUser() {

    const isHost =
        document.getElementById("isHost").checked;

    const playerUuidInput =
        document.getElementById("player-uuid");

    const playerName =
        document.getElementById("player-name")
            .value
            .trim();

    const joinedSession =
        document.getElementById(
            "register-session-uuid"
        ).value.trim();

    const file =
        playerUuidInput.files[0];

    if (!file) {
        alert("Please upload a QR image.");
        return;
    }

    if (!playerName) {
        alert("Please enter a username.");
        return;
    }

    if (!isHost && !joinedSession) {
        alert("Please enter a session ID.");
        return;
    }

    const formData = new FormData();

    formData.append("playerQr", file);
    formData.append("playerName", playerName);

    if (!isHost) {

        formData.append(
            "joinedSession",
            joinedSession
        );
    }

    const response = await fetch(
        "/api/session/register",
        {
            method: "POST",
            body: formData
        }
    );

    const text = await response.text();

    console.log("Register response:", text);

    return {
        status: response.status,
        ok: response.ok,
        data: text
    };
}

/* ---------------- USERS ---------------- */

async function makeUserRequest(params) {

    const userUrl =
        `/api/session/connectedUsers?${new URLSearchParams(params)}`;

    const hostUrl =
        `/api/session/hostName?${new URLSearchParams(params)}`;

    const [response, hostResponse] =
        await Promise.all([
            makeGetRequest(userUrl),
            makeGetRequest(hostUrl)
        ]);

    return {
        response,
        hostResponse
    };
}

async function getCurrentUsers(params) {

    const {
        response,
        hostResponse
    } = await makeUserRequest(params);

    const userList =
        document.getElementById("userList");

    userList.innerHTML = "";

    userElements.clear();

    let users = [];

    try {

        users = JSON.parse(response.body);

    } catch (err) {

        console.error(
            "Failed to parse users:",
            response.body
        );

        return;
    }

    users.forEach((name) => {

        const li =
            document.createElement("li");

        li.textContent = name;

        if (name === hostResponse.body) {

            const crownImg =
                document.createElement("img");

            crownImg.src = "/Web/crown.png";

            crownImg.style.width = "18px";
            crownImg.style.height = "18px";
            crownImg.style.marginLeft = "8px";

            li.style.color = "#6dff8b";
            li.style.fontWeight = "bold";

            li.style.display = "flex";
            li.style.alignItems = "center";

            li.appendChild(crownImg);
        }

        userList.appendChild(li);

        userElements.set(name, li);
    });
}

/* ---------------- LEAVE ---------------- */

async function leaveSession() {
    confirm("You are about to leave the session"); 
    const playerUuid =
        sessionStorage.getItem("playerUuid");
    const sessionToken = sessionStorage.getItem("sessionToken");
    if (!playerUuid) {
        return;
    }

    const url = `/api/session/leaveGame?playerUuid=${playerUuid}&sessionToken=${sessionToken}&ts=${Date.now()}`;

      const response = await fetch(url, {
            method: "POST", 
            keepalive: true
        });

        if (response.status === 404) {
            alert("You are not in a session")

        } else if (response.status === 403) {
            alert("Incorrect session token");
        } 
    stopStream();

    sessionStorage.clear();
    location.reload();
    console.log("Left session");
}

let shouldLeaveSession = true;

window.addEventListener(
    "beforeunload",
    () => {

        if (shouldLeaveSession) {
            leaveSession();
        }
    }
);