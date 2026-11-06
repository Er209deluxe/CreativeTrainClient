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
  if (!uploadedRoleConfig) {
    alert("Please upload a role config.");
    return;
}

if (!uploadedGeneralConfig) {
    alert("Please upload a general config.");
    return;
}

const body = {
    roleConfig: JSON.parse(uploadedRoleConfig),
    generalConfig: JSON.parse(uploadedGeneralConfig)
};

const res = await makePostRequest(
    `/api/session/start?${params.toString()}`,
    "POST",
    body
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
    try {
        const data = JSON.parse(event.data);

        const sanityBar = document.getElementById("sanityBar");
        const depressionBar = document.getElementById("depressionBar");

        if (!sanityBar || !depressionBar) {
            return;
        }

        // ---------------- SANITY ----------------

        const sanity = Number(data.sanity);

        sanityBar.max = 1;
        sanityBar.value = Math.max(0, Math.min(1, sanity));

        sanityBar.style.visibility = "visible";

        // Colour based on sanity level
        if (sanity > 0.66) {
            sanityBar.style.accentColor = "#22c55e";
        } else if (sanity > 0.33) {
            sanityBar.style.accentColor = "#facc15";
        } else {
            sanityBar.style.accentColor = "#ef4444";
        }

        // ---------------- DEPRESSION ----------------

        const depression = Number(data.depression);

        // Your backend uses 1 to indicate that the depression
        // bar should not be displayed.
        if (depression === 1) {
            depressionBar.style.visibility = "hidden";
            depressionBar.value = 1;
            return;
        }

        depressionBar.style.visibility = "visible";

        depressionBar.max = 1;
        depressionBar.value = Math.max(
            0,
            Math.min(1, depression)
        );

        depressionBar.style.accentColor = "#66013d";

    } catch (error) {
        console.error(
            "Failed to process sanityUpdate:",
            event.data,
            error
        );
    }
});
    
    eventSource.addEventListener(
        "failedTransfer",
        (event) => {
            alert(event.data);
        }
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
    "droppedItemsUpdate",
    (event) => {
        try {
            const droppedItems = JSON.parse(event.data);

            displayDroppedItems(droppedItems);
        } catch (error) {
            console.error(
                "Failed to parse droppedItemsUpdate:",
                error,
                event.data
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
    eventSource.addEventListener(
        "questUpdate",
        (event) => {
            document.getElementById("quest").textContent = event.data;
        }
    );
    eventSource.addEventListener(
        "challengeUpdate",
        async (event) => {
            sessionStorage.setItem("challenge", event.data);
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
                sessionStorage.setItem(
                    "roleName",
                    role.name
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
async function uploadChangeRole(victimUuid, challenge) {
    const playerUuid =
        sessionStorage.getItem("playerUuid");

    const sessionToken =
        sessionStorage.getItem("sessionToken");

    const res = await makePostRequest(
        `/api/session/changeRole` +
        `?playerUuid=${encodeURIComponent(playerUuid)}` +
        `&victimUuid=${encodeURIComponent(victimUuid)}` +
        `&challenge=${encodeURIComponent(challenge)}` +
        `&sessionToken=${encodeURIComponent(sessionToken)}` +
        `&ts=${Date.now()}`,
        "POST"
    );

    if (!res.ok) {
        alert(res.body);
        return false;
    }

    return true;
}
window.addEventListener("load", () => {
    const roleName = sessionStorage.getItem("roleName");
    const changeRoleButton =
        document.getElementById("changeRoleButton");

    if (changeRoleButton && roleName === "Amnesiac") {
        changeRoleButton.style.display = "block";
    }
});
function changeRole() {
    return openActionPopup({
        titleText: "Change Role",
        subtitleText:
            "Enter the victim's information to change their role.",
        buttonText: "Change Role",
        buttonColor: "#7c3aed",

        action: (victimUuid, challenge) =>
            uploadChangeRole(victimUuid, challenge)
    });
}
function displayDroppedItems(droppedItems) {
    const container =
        document.getElementById("droppedItemsList");

    if (!container) {
        return;
    }

    container.innerHTML = "";

    if (!droppedItems || droppedItems.length === 0) {
        container.innerHTML =
            "<p>No dropped items.</p>";
        return;
    }

    droppedItems.forEach((dropped) => {
        const item = dropped.item;

        if (!item) {
            return;
        }

        const div = document.createElement("div");
        div.className = "dropped-item";

        const name = document.createElement("span");
        name.textContent = item.name;

        const countdown = document.createElement("span");
        countdown.textContent =
            ` ⏱ ${dropped.countdown}s`;

        const cooldown = document.createElement("span");

        if (item.onCooldown) {
            cooldown.textContent = " 🔴 On Cooldown";
            cooldown.style.color = "#d90408";
        } else {
            cooldown.textContent = " 🟢 Available";
            cooldown.style.color = "#02d926";
        }

        const dropOnDeath = document.createElement("span");

        if (item.dropOnDeath) {
            dropOnDeath.textContent =
                " ☠️ Drops on Death";
        }

        div.appendChild(name);
        div.appendChild(countdown);
        div.appendChild(cooldown);
        div.appendChild(dropOnDeath);

        container.appendChild(div);
    });
}

/* ---------------- STREAM STOP ---------------- */
function completeQuest(){
    const playerUuid = sessionStorage.getItem("playerUuid");
    const sessionToken = sessionStorage.getItem("sessionToken");
    const questInput = document.getElementById("questInput").value.trim();
    makePostRequest(
        `/api/session/completeQuest?playerUuid=${playerUuid}&sessionToken=${sessionToken}&questToken=${encodeURIComponent(questInput)}&ts=${Date.now()}`,
        "POST");
}
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

    if (!inventoryData || !shopData) {
        return;
    }

    const inventoryDiv =
        document.getElementById("Inventory");

    const shopDiv =
        document.getElementById("Shop");

    if (!inventoryDiv || !shopDiv) {
        return;
    }

    /*
     * Only display actual items.
     * Empty inventory slots are ignored.
     */
    inventoryDiv.innerHTML = "";

    inventoryData.forEach((item) => {

        if (!item) {
            return;
        }

        const div =
            document.createElement("div");

        div.className =
            "inventory-slot";

        div.textContent =
            item.name;

        div.onclick = async () => {

            if (await useItem(item)) {
                await loadInventory();
            }

        };

        inventoryDiv.appendChild(div);
    });

    /*
     * Shop
     */
    shopDiv.innerHTML = "";

    shopData.forEach((item) => {

        if (!item) {
            return;
        }

        const div =
            document.createElement("div");

        div.className =
            "shop-item";

        div.textContent =
            `${item.name} - 🪙 ${item.price}`;

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
    if (!item) {
        return false;
    }

    const tags = item.tags || [];

    if (tags.includes("Weapon")) {

        const existingKillToken =
            sessionStorage.getItem("killToken");

        const existingKillItemUuid =
            sessionStorage.getItem("killItemUuid");

        // ------------------------------------------------
        // No active kill -> start kill interaction
        // ------------------------------------------------
        if (!existingKillToken) {
            return await openKillPopup(item);
        }

        // ------------------------------------------------
        // A kill is already active.
        // Make sure the same weapon is being confirmed.
        // ------------------------------------------------
        if (existingKillItemUuid !== item.itemUuid) {
            alert(
                "You already have an active kill interaction."
            );
            return false;
        }

        // ------------------------------------------------
        // Confirm kill
        // ------------------------------------------------
        return await confirmKill();
    }

    console.log("Used item:", item.name);

    return true;
}
function openTransferDropsPopup() {
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

        /* ---------- TITLE ---------- */

        const title = document.createElement("h2");
        title.textContent = "Item Transfer";
        title.style.margin = "0";
        title.style.textAlign = "center";
        title.style.color = "#222";

        const subtitle = document.createElement("p");
        subtitle.textContent =
            "Choose what you want to do and enter the other player's information.";
        subtitle.style.margin = "0";
        subtitle.style.textAlign = "center";
        subtitle.style.color = "#666";

        /* ---------- MODE SELECTOR ---------- */

        const modeContainer = document.createElement("div");

        Object.assign(modeContainer.style, {
            display: "flex",
            gap: "10px",
            background: "#f1f1f1",
            padding: "5px",
            borderRadius: "10px"
        });

        const pickupLabel = document.createElement("label");
        const pickupRadio = document.createElement("input");

        pickupRadio.type = "radio";
        pickupRadio.name = "transferMode";
        pickupRadio.value = "pickup";
        pickupRadio.checked = true;

        pickupLabel.appendChild(pickupRadio);
        pickupLabel.appendChild(
            document.createTextNode(" Pick Up")
        );

        Object.assign(pickupLabel.style, {
            flex: "1",
            padding: "10px",
            textAlign: "center",
            borderRadius: "7px",
            cursor: "pointer",
            color: "#222",
            fontWeight: "bold"
        });

        const transferLabel = document.createElement("label");
        const transferRadio = document.createElement("input");

        transferRadio.type = "radio";
        transferRadio.name = "transferMode";
        transferRadio.value = "transfer";

        transferLabel.appendChild(transferRadio);
        transferLabel.appendChild(
            document.createTextNode(" Transfer")
        );

        Object.assign(transferLabel.style, {
            flex: "1",
            padding: "10px",
            textAlign: "center",
            borderRadius: "7px",
            cursor: "pointer",
            color: "#222",
            fontWeight: "bold"
        });

        modeContainer.append(
            pickupLabel,
            transferLabel
        );

        /* ---------- DESCRIPTION ---------- */

        const modeDescription = document.createElement("p");

        modeDescription.textContent =
            "Pick up items from a dead player.";

        Object.assign(modeDescription.style, {
            margin: "0",
            textAlign: "center",
            color: "#555",
            fontSize: "14px"
        });

        /* ---------- UUID ---------- */

        const uuidLabel = document.createElement("label");
        uuidLabel.textContent = "Player UUID";
        uuidLabel.style.fontWeight = "bold";
        uuidLabel.style.color = "#222";

        const uuidInput = document.createElement("input");

        uuidInput.type = "text";
        uuidInput.placeholder =
            "Enter the other player's UUID";

        Object.assign(uuidInput.style, inputStyle());
        uuidInput.style.color = "#222";

        /* ---------- CHALLENGE ---------- */

        const challengeLabel = document.createElement("label");
        challengeLabel.textContent = "Challenge";
        challengeLabel.style.fontWeight = "bold";
        challengeLabel.style.color = "#222";

        const challengeInput = document.createElement("input");

        challengeInput.type = "text";
        challengeInput.placeholder =
            "Enter current challenge";

        Object.assign(challengeInput.style, inputStyle());
        challengeInput.style.color = "#222";

        /* ---------- BUTTONS ---------- */

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
            color: "#222",
            cursor: "pointer",
            fontWeight: "bold"
        });

        const submitBtn = document.createElement("button");
        submitBtn.textContent = "Pick Up Items";

        Object.assign(submitBtn.style, {
            padding: "10px 18px",
            border: "none",
            borderRadius: "8px",
            background: "#2563eb",
            color: "white",
            cursor: "pointer",
            fontWeight: "bold"
        });

        /* ---------- UPDATE MODE ---------- */

        function updateMode() {

            const pickup = pickupRadio.checked;

            if (pickup) {

                submitBtn.textContent =
                    "Pick Up Items";

                submitBtn.style.background =
                    "#2563eb";

                modeDescription.textContent =
                    "Pick up items from a dead player.";

            } else {

                submitBtn.textContent =
                    "Transfer Items";

                submitBtn.style.background =
                    "#7c3aed";

                modeDescription.textContent =
                    "Give your dropped items to another living player.";
            }
        }

        pickupRadio.addEventListener(
            "change",
            updateMode
        );

        transferRadio.addEventListener(
            "change",
            updateMode
        );

        /* ---------- SUBMIT ---------- */

        submitBtn.onclick = async () => {

            const otherPlayerUuid =
                uuidInput.value.trim();

            const challenge =
                challengeInput.value.trim();

            const pickup =
                pickupRadio.checked;

            if (
                !otherPlayerUuid ||
                !challenge
            ) {
                alert(
                    "Please enter both the player UUID and the challenge."
                );

                return;
            }

            const playerUuid =
                sessionStorage.getItem("playerUuid");

            const sessionToken =
                sessionStorage.getItem("sessionToken");

            if (!playerUuid || !sessionToken) {

                alert(
                    "Missing session information."
                );

                return;
            }

            const params =
                new URLSearchParams({
                    playerUuid,
                    sessionToken,
                    challenge,
                    victimUuid: otherPlayerUuid,
                    pickup: pickup.toString(),
                    ts: Date.now().toString()
                });

            const res =
                await makePostRequest(
                    `/api/session/transferDrops?${params.toString()}`,
                    "POST"
                );

            if (!res.ok) {

                alert(
                    res.body ||
                    "Failed to transfer items."
                );

                return;
            }

            /*
             * The backend returns an empty response
             * when everything was successful.
             *
             * If some items failed, it returns the
             * explanation as the response body.
             */

            if (res.body && res.body.trim()) {

                alert(res.body);

            } else {

                alert(
                    pickup
                        ? "Items picked up successfully!"
                        : "Items transferred successfully!"
                );
            }

            await loadInventory();

            document.body.removeChild(overlay);

            resolve(true);
        };

        /* ---------- CANCEL ---------- */

        cancelBtn.onclick = () => {

            document.body.removeChild(overlay);

            resolve(false);
        };

        /* ---------- BUILD ---------- */

        buttonRow.append(
            cancelBtn,
            submitBtn
        );

        box.append(
            title,
            subtitle,
            modeContainer,
            modeDescription,
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
}


async function pickupDroppedItems(victimUuid, challenge) {
    const playerUuid = sessionStorage.getItem("playerUuid");
    const sessionToken = sessionStorage.getItem("sessionToken");

    if (!playerUuid || !sessionToken) {
        alert("Missing session information.");
        return false;
    }

    const params = new URLSearchParams({
        playerUuid: playerUuid,
        sessionToken: sessionToken,
        challenge: challenge,
        victimUuid: victimUuid,
        ts: Date.now().toString()
    });

    const res = await makePostRequest(
        `/api/session/pickupDrops?${params.toString()}`,
        "POST"
    );

    if (!res.ok) {
        alert(res.body || "Failed to pick up dropped items.");
        return false;
    }

    // The endpoint returns a message when some items couldn't
    // be picked up, otherwise the response body is empty.
    if (res.body && res.body.trim()) {
        alert(res.body);
    } else {
        alert("Dropped items picked up successfully!");
    }

    // Refresh the inventory after picking items up.
    await loadInventory();

    return true;
}

async function startKillInteraction(item, victimUuid, challenge) {
    const playerUuid = sessionStorage.getItem("playerUuid");
    const sessionToken = sessionStorage.getItem("sessionToken");
    const sessionUuid = sessionStorage.getItem("sessionUuid");

    const res = await makePostRequest(
        `/api/session/killInteraction` +
        `?killerUuid=${encodeURIComponent(playerUuid)}` +
        `&sessionToken=${encodeURIComponent(sessionToken)}` +
        `&challenge=${encodeURIComponent(challenge)}` +
        `&victimUuid=${encodeURIComponent(victimUuid)}` +
        `&itemUuid=${encodeURIComponent(item.itemUuid)}` +
        `&sessionUuid=${encodeURIComponent(sessionUuid)}` +
        `&ts=${Date.now()}`,
        "POST"
    );

    if (!res.ok) {
        alert(res.body);
        return false;
    }

    // Backend returns the killToken as plain text
    const killToken = res.body.trim();

    if (!killToken) {
        alert("No kill token received.");
        return false;
    }

    sessionStorage.setItem("killToken", killToken);

    console.log("Kill interaction started.");
    console.log("Kill token:", killToken);

    return true;
}


async function confirmKill() {
    const playerUuid = sessionStorage.getItem("playerUuid");
    const sessionToken = sessionStorage.getItem("sessionToken");
    const sessionUuid = sessionStorage.getItem("sessionUuid");
    const killToken = sessionStorage.getItem("killToken");

    if (!killToken) {
        alert("No active kill interaction.");
        return false;
    }

    const res = await makePostRequest(
        `/api/session/kill` +
        `?killerUuid=${encodeURIComponent(playerUuid)}` +
        `&sessionToken=${encodeURIComponent(sessionToken)}` +
        `&sessionUuid=${encodeURIComponent(sessionUuid)}` +
        `&killToken=${encodeURIComponent(killToken)}` +
        `&ts=${Date.now()}`,
        "POST"
    );

    if (!res.ok) {
        alert(res.body);

        // Optional: remove token if the server rejected it
        sessionStorage.removeItem("killToken");

        return false;
    }

    // Kill succeeded, so the token should no longer be used
    sessionStorage.removeItem("killToken");

    console.log("Kill successful.");

    return true;
}
function openKillPopup(item) {
    return openActionPopup({
        titleText: `Use ${item.name}`,
        subtitleText:
            "Enter the victim's information to start the kill.",
        buttonText: "Start Kill",
        buttonColor: "#dc2626",

        action: async (victimUuid, challenge) => {
            return await startKillInteraction(
                item,
                victimUuid,
                challenge
            );
        }
    });
}

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
function openActionPopup({
    titleText,
    subtitleText,
    buttonText,
    buttonColor,
    action
}) {
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
        title.textContent = titleText;
        title.style.margin = "0";
        title.style.textAlign = "center";
        title.style.color = "#222";

        const subtitle = document.createElement("p");
        subtitle.textContent = subtitleText;
        subtitle.style.margin = "0";
        subtitle.style.textAlign = "center";
        subtitle.style.color = "#666";

        const uuidLabel = document.createElement("label");
        uuidLabel.textContent = "Victim UUID";
        uuidLabel.style.fontWeight = "bold";
        uuidLabel.style.color = "#222";

        const uuidInput = document.createElement("input");
        uuidInput.type = "text";
        uuidInput.placeholder =
            "e.g. a23390c2-b829-418e-8971-8dcd6dee5d8e";
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
        submitBtn.textContent = buttonText;

        Object.assign(submitBtn.style, {
            padding: "10px 18px",
            border: "none",
            borderRadius: "8px",
            background: buttonColor,
            color: "white",
            cursor: "pointer",
            fontWeight: "bold"
        });

        submitBtn.onclick = async () => {
            const victimUuid = uuidInput.value.trim();
            const challenge = challengeInput.value.trim();

            if (!victimUuid || !challenge) {
                alert(
                    "Please enter both the victim UUID and the challenge."
                );
                return;
            }

            const success = await action(
                victimUuid,
                challenge
            );

            document.body.removeChild(overlay);
            resolve(success);
        };

        cancelBtn.onclick = () => {
            document.body.removeChild(overlay);
            resolve(false);
        };

        buttonRow.append(
            cancelBtn,
            submitBtn
        );

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
}
async function startKillInteraction(item, victimUuid, challenge) {
    const killerUuid = sessionStorage.getItem("playerUuid");
    const sessionToken = sessionStorage.getItem("sessionToken");
    const sessionUuid = sessionStorage.getItem("sessionUuid");

    if (!killerUuid || !sessionToken || !sessionUuid) {
        alert("Missing session information.");
        return false;
    }

    if (!item || !item.itemUuid) {
        alert("Invalid kill item.");
        return false;
    }

    const params = new URLSearchParams({
        killerUuid: killerUuid,
        sessionToken: sessionToken,
        challenge: challenge,
        victimUuid: victimUuid,
        itemUuid: item.itemUuid,
        sessionUuid: sessionUuid,
        ts: Date.now().toString()
    });

    const res = await makePostRequest(
        `/api/session/killInteraction?${params.toString()}`,
        "POST"
    );

    if (!res.ok) {
        console.error(
            "Kill interaction failed:",
            res.status,
            res.body
        );

        alert(res.body || "Failed to start kill interaction.");
        return false;
    }

    const killToken = res.body.trim();

    if (!killToken) {
        alert("Server did not return a kill token.");
        return false;
    }

    sessionStorage.setItem("killToken", killToken);

    // Remember which item created the token.
    sessionStorage.setItem(
        "killItemUuid",
        item.itemUuid
    );

    console.log("Kill interaction started.");

    return true;
}


async function confirmKill() {
    const killerUuid = sessionStorage.getItem("playerUuid");
    const sessionToken = sessionStorage.getItem("sessionToken");
    const sessionUuid = sessionStorage.getItem("sessionUuid");
    const killToken = sessionStorage.getItem("killToken");

    if (!killerUuid || !sessionToken || !sessionUuid) {
        alert("Missing session information.");
        return false;
    }

    if (!killToken) {
        alert("No active kill interaction.");
        return false;
    }

    const params = new URLSearchParams({
        killerUuid: killerUuid,
        sessionToken: sessionToken,
        sessionUuid: sessionUuid,
        killToken: killToken,
        ts: Date.now().toString()
    });

    const res = await makePostRequest(
        `/api/session/kill?${params.toString()}`,
        "POST"
    );

    if (!res.ok) {
        console.error(
            "Kill request failed:",
            res.status,
            res.body
        );

        alert(res.body || "Kill failed.");

        // The token should not be reused after a failed attempt
        // if the backend invalidates it.
        sessionStorage.removeItem("killToken");
        sessionStorage.removeItem("killItemUuid");

        return false;
    }

    // Token is single-use.
    sessionStorage.removeItem("killToken");
    sessionStorage.removeItem("killItemUuid");

    console.log("Kill successful.");

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