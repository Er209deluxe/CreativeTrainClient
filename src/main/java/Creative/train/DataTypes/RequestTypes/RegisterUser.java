package Creative.train.DataTypes.RequestTypes;

import java.util.UUID;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;

public class RegisterUser {

    private final UUID playerUuid;
    private final String playerName;
    private final UUID joinedSession;

    @JsonCreator
    public RegisterUser(
            @JsonProperty("playerUuid") UUID playerUuid,
            @JsonProperty("playerName") String playerName,
            @JsonProperty("joinedSession") UUID joinedSession
    )
    {
        this.playerUuid = playerUuid;
        this.playerName = playerName;
        this.joinedSession = joinedSession;
    }

    public UUID getPlayerUuid() { return playerUuid; }
    public String getPlayerName() { return playerName; }
    public UUID getJoinedSession() { return joinedSession; }
}