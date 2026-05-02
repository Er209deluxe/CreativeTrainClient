package Creative.train.DataTypes;

import java.util.UUID;

public class Player {
    private boolean isAlive=true;
    private final String name;
    private final UUID playerId;
    public Player(String name, UUID playerId){
        this.name = name;
        this.playerId = playerId;
    }

    public String getName() {
        return name;
    }

    public UUID getPlayerId() {
        return playerId;
    }
    public void setAlive(boolean alive){
        isAlive=alive;
    }

    public boolean isAlive() {
        return isAlive;
    }
}
