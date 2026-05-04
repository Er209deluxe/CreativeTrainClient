package Creative.train.DataTypes.RequestTypes;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.UUID;

public class PlayerInformation {
    private final UUID sessionId;
    private final UUID playerUuid;
    @JsonCreator
    public PlayerInformation(
        @JsonProperty("sessionId") UUID sessionId,
        @JsonProperty("hostUuid") UUID hostUuid

    )
        {
            this.sessionId = sessionId;
            this.playerUuid = hostUuid;
        }

    public UUID getPlayerUuid() {
        return playerUuid;
    }

    public UUID getSessionId() {
        return sessionId;
    }
}
