package Creative.train.DataTypes.RequestTypes;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.UUID;

public class PlayerInformation {

    private final UUID sessionId;
    private final UUID playerUuid;
    private final String sessionToken; // optional

    @JsonCreator
    public PlayerInformation(
            @JsonProperty("sessionId") UUID sessionId,
            @JsonProperty("playerUuid") UUID playerUuid,
            @JsonProperty("sessionToken") String sessionToken
    ) {
        this.sessionId = sessionId;
        this.playerUuid = playerUuid;
        this.sessionToken = sessionToken;
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