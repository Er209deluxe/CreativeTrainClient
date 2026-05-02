package Creative.train.DataTypes;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class Session {
    private boolean active;
    private final UUID sessionId;
    private final List<Player> playerList = new ArrayList<>();

    public Session(){
        sessionId = UUID.randomUUID();
    }

    public void setActive() {
        this.active = true;
    }
    public void addPlayer(Player player){
        playerList.add(player);
    }

    public UUID getSessionId() {
        return sessionId;
    }

    public List<Player> getPlayerList() {
        return playerList;
    }
}
