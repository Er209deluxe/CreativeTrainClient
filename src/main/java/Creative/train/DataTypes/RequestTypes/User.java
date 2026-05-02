package Creative.train.DataTypes.RequestTypes;

import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.web.multipart.MultipartFile;

public class User {
    private UUID playerUuid;
    private final MultipartFile playerQr;
    private final String playerName;
    private final UUID joinedSession;
    private final boolean isHost;

    @JsonCreator
    public User(
            @JsonProperty("playerUuid") MultipartFile playerUuid,
            @JsonProperty("playerName") String playerName,
            @JsonProperty("joinedSession") UUID joinedSession
    ) {
        this.playerQr = playerUuid;
        this.playerName = playerName;
        this.joinedSession = joinedSession;
        this.isHost = (joinedSession == null); // infer host

    }

    public boolean isHost() {
        return isHost;
    }

    public MultipartFile getPlayerQr() {
        return playerQr;
    }

    public void setPlayerUuid(UUID playerUuid) {
        this.playerUuid = playerUuid;
    }

    public UUID getPlayerUuid() { return playerUuid; }
    public String getPlayerName() { return playerName; }
    public UUID getJoinedSession() { return joinedSession; }
}