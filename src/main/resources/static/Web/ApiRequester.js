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
    const sessionUuid = sessionStorage.getItem("sessionUuid");
    const playerUuid = sessionStorage.getItem("playerUuid");

    const params = new URLSearchParams({
        token: sessionStorage.getItem("sessionToken"),
        ts: Date.now().toString(),
        sessionUuid,
        playerUuid,
    });

    // Parse the uploaded JSON file into an object
    const roleConfig = JSON.parse(uploadedRoleConfig);

    const res = await makePostRequest(
        `/api/session/start?${params.toString()}`,
        "POST",
        roleConfig
    );

    console.log(res);

    if (!res.ok) {
        alert("Failed to start session: " + res.body);
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

     eventSource.addEventListener("sanityUpdate", (event) => {
    const data = JSON.parse(event.data);

    const sanityBar = document.getElementById("sanityBar");
    sanityBar.style.color = "#ffffff";
    const depressionBar = document.getElementById("depressionBar");

    sanityBar.value = data.sanity;

    if (data.depression === 1) {
        depressionBar.style.visibility = "hidden";
        return;
    }

    depressionBar.style.visibility = "visible";
    depressionBar.style.color = "#66013d"; 
    depressionBar.value = data.depression;
});
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
        "deathEvent",
        (event) => {
            alert("You have been killed!");
        }
    );
             eventSource.addEventListener(
        "sessionEnd",
        (event) => {
            showPlayerPopup(JSON.parse(event.data));
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

            }, 9000);
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
const teamColors = {
    KILLER: "#d90408",
    CIVILIAN: "#02d926",
    NEUTRAL: "#888888"
};
function closePopup() {
    document.getElementById("playerPopup").classList.add("hidden");
    window.location.href = "/"; // Redirect to the main page
}
function showPlayerPopup(data) {
    document.getElementById("playerPopup").classList.remove("hidden");
    const winnerEl = document.getElementById("winner");
    winnerEl.innerText =  data.winnerTeam+"S have won the game!";
    winnerEl.style.color = teamColors[data.winnerTeam] || "white";
        document.getElementById("reason").innerText =
        data.reason;
    // clear old data
    document.querySelectorAll(".player-list").forEach(el => el.innerHTML = "");

    data.playerDataList.forEach(p => {
        const team = p.role.team; // KILLER / CIVILIAN / NEUTRAL
        const container = document.querySelector(`#${team} .player-list`);

        if (!container) return;

        const div = document.createElement("div");
        div.className = "player";

        div.innerText = p.playerName;

        // 🎨 role color
        div.style.color = p.role.hex;

        // ☠️ dead player = red override
        if (!p.isAlive) {
            div.style.textDecoration = "line-through";
        }

        // 🧾 tooltip = role name
        div.title = `${p.role.name}`;

        container.appendChild(div);
    });
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
 async function getInventory(isShop) {
    const playerUuid = sessionStorage.getItem("playerUuid");
    const sessionToken = sessionStorage.getItem("sessionToken");

    const res = await makeGetRequest(
        `/api/session/inventory?playerUuid=${playerUuid}&sessionToken=${sessionToken}&isShop=${isShop}&ts=${Date.now()}`
    );

    if (!res.ok) {
        console.error("Failed to get inventory:", res.body);
        return null;
    }

    return JSON.parse(res.body);
}
async function loadInventory() {
    const inventoryData = await getInventory(false);
    const shopData = await getInventory(true);

    if (!inventoryData || !shopData) return;

    const inventoryDiv = document.getElementById("Inventory");
    const shopDiv = document.getElementById("Shop");

    if (!inventoryDiv || !shopDiv) return;

    inventoryDiv.innerHTML = "<h2>Inventory</h2>";
    shopDiv.innerHTML = "<h2>Shop</h2>";



     inventoryData.forEach((item, index) => {
        const div = document.createElement("div");
        div.className = "inventory-slot";

        div.textContent = item
            ? `${item.name}`
            : `Slot ${index + 1}: Empty`;

                div.onclick = async () => {
            if (item && await useItem(item)) {
                await loadInventory();
            }
        };
        inventoryDiv.appendChild(div);
    });

    shopData.forEach(item => {
        const div = document.createElement("div");
        div.className = "shop-item";

        div.textContent = `${item.name} - 🪙 ${item.price}`;

        div.onclick = async () => {
            if (await buyItem(item.itemUuid)) {
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
        `&itemUuid=${encodeURIComponent(item)}` +
        `&ts=${Date.now()}`,
        "POST"
    );

    if (!res.ok) {
        alert(res.body);
        return false;
    }

    return true;
}
async function useItem(item) {
    if (!item) return false;

    const tags = item.tags || [];

    if (tags.includes("Weapon")) {
        return await openKillPopup(item);
    }

    // default behavior for non-weapons
    console.log("Used item:", item.name);
    return true;
}function openKillPopup(item) {
    return new Promise((resolve) => {
        const overlay = document.createElement("div");
        Object.assign(overlay.style, {
            position: "fixed",
            inset: "0",
            background: "rgba(0,0,0,0.65)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            zIndex: "9999",
            backdropFilter: "blur(4px)"
        });

        const box = document.createElement("div");
        Object.assign(box.style, {
            background: "#ffffff",
            borderRadius: "16px",
            padding: "28px",
            width: "420px",
            maxWidth: "90%",
            boxShadow: "0 12px 30px rgba(0,0,0,0.3)",
            display: "flex",
            flexDirection: "column",
            gap: "16px",
            fontFamily: "Arial, sans-serif"
        });

        const title = document.createElement("h2");
        title.textContent = `Use ${item.name}`;
        title.style.margin = "0";
        title.style.textAlign = "center";
        title.style.color = "#222";

        const subtitle = document.createElement("p");
        subtitle.textContent = "Enter the victim's information to confirm the kill.";
        subtitle.style.margin = "0";
        subtitle.style.textAlign = "center";
        subtitle.style.color = "#666";

        const uuidLabel = document.createElement("label");
        uuidLabel.textContent = "Victim UUID";
        uuidLabel.style.fontWeight = "bold";
        uuidLabel.style.color = "#222";

        const uuidInput = document.createElement("input");
        uuidInput.type = "text";
        uuidInput.placeholder = "e.g. a23390c2-b829-418e-8971-8dcd6dee5d8e";
        uuidInput.style.color = "#222";
        Object.assign(uuidInput.style, inputStyle());

        const challengeLabel = document.createElement("label");
        challengeLabel.textContent = "Challenge";
        challengeLabel.style.fontWeight = "bold";
        challengeLabel.style.color = "#222";
        const challengeInput = document.createElement("input");
        challengeInput.type = "text";
        challengeInput.placeholder = "Enter current challenge";
        challengeInput.style.color = "#222";

        Object.assign(challengeInput.style, inputStyle());

        const buttonRow = document.createElement("div");
        Object.assign(buttonRow.style, {
            display: "flex",
            justifyContent: "flex-end",
            gap: "12px",
            marginTop: "8px"
        });

        const cancelBtn = document.createElement("button");
        cancelBtn.textContent = "Cancel";
        Object.assign(cancelBtn.style, {
            padding: "10px 18px",
            border: "none",
            borderRadius: "8px",
            background: "#d1d5db",
            cursor: "pointer",
            fontWeight: "bold"
        });

        const submitBtn = document.createElement("button");
        submitBtn.textContent = "Confirm Kill";
        Object.assign(submitBtn.style, {
            padding: "10px 18px",
            border: "none",
            borderRadius: "8px",
            background: "#dc2626",
            color: "white",
            cursor: "pointer",
            fontWeight: "bold"
        });

        submitBtn.onclick = async () => {
            const victimUuid = uuidInput.value.trim();
            const challenge = challengeInput.value.trim();

            if (!victimUuid || !challenge) {
                alert("Please enter both the victim UUID and the challenge.");
                return;
            }

            const success = await uploadKill(item, victimUuid, challenge);

            document.body.removeChild(overlay);
            resolve(success);
        };

        cancelBtn.onclick = () => {
            document.body.removeChild(overlay);
            resolve(false);
        };

        buttonRow.append(cancelBtn, submitBtn);

        box.append(
            title,
            subtitle,
            uuidLabel,
            uuidInput,
            challengeLabel,
            challengeInput,
            buttonRow
        );

        overlay.appendChild(box);
        document.body.appendChild(overlay);

        uuidInput.focus();
    });

    function inputStyle() {
        return {
            padding: "12px",
            border: "1px solid #ccc",
            borderRadius: "8px",
            fontSize: "14px",
            outline: "none",
            width: "100%",
            boxSizing: "border-box"
        };
    }
}
async function uploadKill(item, victimUuid, challenge) {
    const playerUuid = sessionStorage.getItem("playerUuid");
    const sessionToken = sessionStorage.getItem("sessionToken");

    const res = await makePostRequest(
        `/api/session/kill?killerUuid=${playerUuid}` +
        `&sessionToken=${sessionToken}` +
        `&itemUuid=${encodeURIComponent(item.itemUuid)}` +
        `&victimUuid=${encodeURIComponent(victimUuid)}` +
        `&challenge=${encodeURIComponent(challenge)}` +
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