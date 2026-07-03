/* ---------------- REQUEST HELPERS ---------------- */

async function makePostRequest(
    url,
    method,
    data = null
) {

    const response = await fetch(url, {
        method,
        headers: data
            ? {
                  "Content-Type":
                      "application/json"
              }
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

/* ---------------- GLOBALS ---------------- */

let eventSource = null;

const userElements = new Map();

let shouldLeaveSession = true;

/* ---------------- QR ---------------- */

async function generatePlayerQr() {

    document.getElementById(
        "qrCode"
    ).src =
        "/api/newPlayerQr?ts=" +
        Date.now();
}

/* ---------------- SESSION ---------------- */

async function startSession() {

    const sessionId =
        sessionStorage.getItem(
            "sessionUuid"
        );

    const playerUuid =
        sessionStorage.getItem(
            "playerUuid"
        );

    const roleConfig =
        encodeURIComponent(
            uploadedRoleConfig || ""
        );

    const res =
        await makePostRequest(
            "/api/session/start" +
                "?sessionToken=" +
                sessionStorage.getItem(
                    "sessionToken"
                ) +
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

        alert(
            "Failed to start session: " +
                res.body
        );

        return;
    }

}

/* ---------------- STREAM ---------------- */

function startStream() {

    if (eventSource) {

        console.log(
            "Stream already active"
        );

        return;
    }

    const playerUuid =
        sessionStorage.getItem(
            "playerUuid"
        );

    const sessionToken =
        sessionStorage.getItem(
            "sessionToken"
        );

    if (
        !playerUuid ||
        !sessionToken
    ) {

        console.log(
            "Missing session info"
        );

        return;
    }

    const url =
        `/api/stream?playerUuid=${playerUuid}&sessionToken=${sessionToken}&ts=${Date.now()}`;

    eventSource =
        new EventSource(url);

    console.log("Stream started");

    const userList =
        document.getElementById(
            "userList"
        );

    /* ---------- JOIN ---------- */

    eventSource.addEventListener(
        "playerJoined",
        (event) => {

            const name =
                event.data;

            console.log(
                "Joined:",
                name
            );

            if (
                userElements.has(name)
            ) {
                return;
            }

            if (!userList) {
                return;
            }

            const li =
                document.createElement(
                    "li"
                );

            li.textContent = name;

            userList.appendChild(li);

            userElements.set(
                name,
                li
            );
        }
    );
   
    /* ---------- DISCONNECT ---------- */

    eventSource.addEventListener(
        "playerDisconnected",
        (event) => {

            const name =
                event.data;

            console.log(
                "Disconnected:",
                name
            );

            const element =
                userElements.get(
                    name
                );

            if (element) {

                element.remove();

                userElements.delete(
                    name
                );
            }
        }
    );
      eventSource.addEventListener(
        "coinUpdate",
        (event) => {
            document.getElementById("coinCount").textContent = event.data;
        }
    );
          eventSource.addEventListener(
        "timerUpdate",
        (event) => {
            document.getElementById("timer").textContent = event.data;
        }
    );

    /* ---------- SESSION START ---------- */

    eventSource.addEventListener(
        "sessionStart",
        (event) => {

            const role =
                JSON.parse(
                    event.data
                );

            showTransition(
                `Session Started! Role: ${role.name}`,
                role.hex
            );

            setTimeout(() => {

                shouldLeaveSession = false;

                window.location.href =
                    "activeGame?sessionUuid=" +
                    sessionStorage.getItem(
                        "sessionUuid"
                    );

            }, 3000);
        }
    );

    /* ---------- ERROR ---------- */

    eventSource.onerror =
        async (err) => {

            console.log(
                "SSE error",
                err
            );

            try {

                const response =
                    await fetch(url, {
                        method: "GET"
                    });

                if (
                    response.status ===
                    404
                ) {

                    console.log(
                        "Player not found"
                    );
                }
                else if (
                    response.status ===
                    403
                ) {

                    console.log(
                        "Forbidden"
                    );
                }
                else {

                    console.log(
                        "Unknown SSE error"
                    );
                }

            } catch (e) {

                console.error(
                    "Network error",
                    e
                );
            }

            stopStream();
        };
}

/* ---------------- STREAM STOP ---------------- */

function stopStream() {

    if (eventSource) {

        eventSource.close();

        eventSource = null;

        console.log(
            "Stream stopped"
        );
    }
}
 async function getInventory() {
    const playerUuid = sessionStorage.getItem("playerUuid");
    const sessionToken = sessionStorage.getItem("sessionToken");

    const res = await makeGetRequest(
        `/api/session/inventory?playerUuid=${playerUuid}&sessionToken=${sessionToken}&ts=${Date.now()}`
    );

    if (!res.ok) {
        console.error("Failed to get inventory:", res.body);
        return null;
    }

    return JSON.parse(res.body);
}
async function loadInventory() {
    const data = await getInventory();
    if (!data) return;

    const inventoryDiv = document.getElementById("Inventory");
    const shopDiv = document.getElementById("Shop");

    if (!inventoryDiv || !shopDiv) return;

    inventoryDiv.innerHTML = "<h2>Inventory</h2>";
    shopDiv.innerHTML = "<h2>Shop</h2>";

    // Inventory
    data.inventory.forEach((item, index) => {
        const div = document.createElement("div");
        div.className = "inventory-slot";

        div.textContent = item
            ? `${item.name}`
            : `Slot ${index + 1}: Empty`;

        inventoryDiv.appendChild(div);
    });

    // Shop
    data.shop.forEach(item => {
    const div = document.createElement("div");
    div.className = "shop-item";

    div.textContent = `${item.name} - 🪙 ${item.price}`;

    div.onclick = async () => {
        if (await buyItem(item.name)) {
            await loadInventory();
        }
    };

    shopDiv.appendChild(div);
});
}
async function buyItem(item) {
    const playerUuid = sessionStorage.getItem("playerUuid");
    const sessionToken = sessionStorage.getItem("sessionToken");

    const res = await makePostRequest(
        `/api/session/buyItem?playerUuid=${playerUuid}` +
        `&sessionToken=${sessionToken}` +
        `&item=${encodeURIComponent(item)}` +
        `&ts=${Date.now()}`,
        "POST"
    );

    if (!res.ok) {
        alert(res.body);
        return false;
    }

    return true;
}
/* ---------------- TRANSITION ---------------- */

function showTransition(
    text = "Loading...",
    color = "#fff"
) {

    const screen =
        document.getElementById(
            "transitionScreen"
        );

    if (!screen) {
        return;
    }

    screen.textContent = text;

    screen.style.color = color;

    screen.classList.add(
        "active"
    );
}

function hideTransition() {

    const screen =
        document.getElementById(
            "transitionScreen"
        );

    if (!screen) {
        return;
    }

    screen.classList.remove(
        "active"
    );
}

/* ---------------- REGISTER ---------------- */

async function registerAndConnect() {

    

    const isHost =
        document.getElementById(
            "isHost"
        ).checked;

    const result =
        await registerUser();

    if (
        !result ||
        !result.ok
    ) {

        alert(
            "Registration failed: " +
                (result
                    ? result.data
                    : "Unknown error")
        );

        return;
    }

    let data;

    try {

        data = JSON.parse(
            result.data
        );

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
        data.sessionUuid;

    const sessionToken =
        data.token;

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

    const sessionDisplay =
        document.getElementById(
            "sessionUuidDisplay"
        );

    if (sessionDisplay) {

        sessionDisplay.innerText =
            sessionUuid;
    }

    const registrationSection =
        document.getElementById(
            "registrationSection"
        );

    if (
        registrationSection
    ) {

        registrationSection.style.display =
            "none";
    }

    if (isHost) {

        const hostConfig =
            document.getElementById(
                "hostConfigSection"
            );

        const startButton =
            document.getElementById(
                "startSessionButton"
            );

        if (hostConfig) {

            hostConfig.style.display =
                "block";
        }

        if (startButton) {

            startButton.style.display =
                "block";
        }
    }

    console.log(
        "Connected:",
        playerUuid
    );

    startStream();

    await getCurrentUsers({
        sessionUuid
    });
}

async function registerUser() {

    const isHost =
        document.getElementById(
            "isHost"
        ).checked;

    const playerUuidInput =
        document.getElementById(
            "player-uuid"
        );

    const playerName =
        document
            .getElementById(
                "player-name"
            )
            .value.trim();

    const joinedSession =
        document
            .getElementById(
                "register-session-uuid"
            )
            .value.trim();

    const file =
        playerUuidInput.files[0];

    if (!file) {

        alert(
            "Please upload a QR image."
        );

        return;
    }

    if (!playerName) {

        alert(
            "Please enter a username."
        );

        return;
    }

    if (
        !isHost &&
        !joinedSession
    ) {

        alert(
            "Please enter a session ID."
        );

        return;
    }

    const formData =
        new FormData();

    formData.append(
        "playerQr",
        file
    );

    formData.append(
        "playerName",
        playerName
    );

    if (!isHost) {

        formData.append(
            "joinedSession",
            joinedSession
        );
    }

    const response =
        await fetch(
            "/api/session/register",
            {
                method: "POST",
                body: formData
            }
        );

    const text =
        await response.text();

    console.log(
        "Register response:",
        text
    );

    return {
        status:
            response.status,
        ok: response.ok,
        data: text
    };
}

/* ---------------- USERS ---------------- */

async function makeUserRequest(
    params
) {

    const userUrl =
        `/api/session/connectedUsers?${new URLSearchParams(params)}`;

    const hostUrl =
        `/api/session/hostName?${new URLSearchParams(params)}`;

    const [
        response,
        hostResponse
    ] = await Promise.all([
        makeGetRequest(
            userUrl
        ),
        makeGetRequest(
            hostUrl
        )
    ]);

    return {
        response,
        hostResponse
    };
}

async function getCurrentUsers(
    params
) {

    const {
        response,
        hostResponse
    } =
        await makeUserRequest(
            params
        );

    const userList =
        document.getElementById(
            "userList"
        );

    if (!userList) {
        return;
    }

    userList.innerHTML = "";

    userElements.clear();

    let users = [];

    try {

        users = JSON.parse(
            response.body
        );

    } catch (err) {

        console.error(
            "Failed to parse users:",
            response.body
        );

        return;
    }

    users.forEach((name) => {

        const li =
            document.createElement(
                "li"
            );

        li.textContent = name;

        if (
            name ===
            hostResponse.body
        ) {

            const crownImg =
                document.createElement(
                    "img"
                );

            crownImg.src =
                "/Web/crown.png";

            crownImg.style.width =
                "18px";

            crownImg.style.height =
                "18px";

            crownImg.style.marginLeft =
                "8px";

            li.style.color =
                "#6dff8b";

            li.style.fontWeight =
                "bold";

            li.style.display =
                "flex";

            li.style.alignItems =
                "center";

            li.appendChild(
                crownImg
            );
        }

        userList.appendChild(li);

        userElements.set(
            name,
            li
        );
    });
}

/* ---------------- LEAVE ---------------- */

async function leaveSession() {

    if (
        !confirm(
            "You are about to leave the session"
        )
    ) {
        return;
    }

    const playerUuid =
        sessionStorage.getItem(
            "playerUuid"
        );

    const sessionToken =
        sessionStorage.getItem(
            "sessionToken"
        );

    if (!playerUuid) {
        return;
    }

    const url =
        `/api/session/leaveGame?playerUuid=${playerUuid}&sessionToken=${sessionToken}&ts=${Date.now()}`;

    try {

        const response =
            await fetch(url, {
                method: "POST",
                keepalive: true
            });

        if (
            response.status ===
            404
        ) {

            alert(
                "You are not in a session"
            );
        }
        else if (
            response.status ===
            403
        ) {

            alert(
                "Incorrect session token"
            );
        }

    } catch (err) {

        console.error(
            "Leave error:",
            err
        );
    }

    stopStream();

    sessionStorage.clear();

    location.reload();

    console.log(
        "Left session"
    );
}

/* ---------------- AUTO RECONNECT ---------------- */

window.addEventListener(
    "load",
    async () => {

        const playerUuid =
            sessionStorage.getItem(
                "playerUuid"
            );

        const sessionUuid =
            sessionStorage.getItem(
                "sessionUuid"
            );

        if (
            playerUuid &&
            sessionUuid
        ) {

            shouldLeaveSession =
                false;

            startStream();

            await getCurrentUsers({
                sessionUuid
            });
        }
    }
);

/* ---------------- PAGE LEAVE ---------------- */

window.addEventListener(
    "beforeunload",
    () => {

        if (
            shouldLeaveSession
        ) {

            navigator.sendBeacon(
                `/api/session/leaveGame?playerUuid=${sessionStorage.getItem("playerUuid")}&sessionToken=${sessionStorage.getItem("sessionToken")}`
            );
        }
    }
);