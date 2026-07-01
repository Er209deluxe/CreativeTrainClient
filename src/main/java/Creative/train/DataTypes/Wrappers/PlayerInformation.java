package Creative.train.DataTypes.Wrappers;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.UUID;

public class PlayerInformation {
    //TODO : replace all uses with PlayerData
    private final UUID sessionId;
    private final UUID playerUuid;
    private final String sessionToken; // optional
    private final boolean isHost;
    @JsonCreator
    public PlayerInformation(
            @JsonProperty("sessionId") UUID sessionId,
            @JsonProperty("playerUuid") UUID playerUuid,
            @JsonProperty("sessionToken") String sessionToken,
            boolean isHost
    ) {
        this.sessionId = sessionId;
        this.playerUuid = playerUuid;
        this.sessionToken = sessionToken;
        this.isHost = isHost;
    }

    public boolean isHost() {
        return isHost;
    }

    public UUID getPlayerUuid() {
        return playerUuid;
    }

    public UUID getSessionId() {
        return sessionId;
    }

    public String getSessionToken() {
        return sessionToken;
    }
}