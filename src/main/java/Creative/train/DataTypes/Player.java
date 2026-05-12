package Creative.train.DataTypes;

import Creative.train.GameLogic.Roles.Innocent;
import Creative.train.GameLogic.Roles.Killer;
import Creative.train.GameLogic.Roles.Role;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.UUID;

public class Player {
    private boolean isAlive=true;
    private final String name;
    private final UUID playerId;
    private final boolean isHost;
    private SseEmitter connection;
    private UUID sessionUUID;
    Role role;
    public Player(String name, UUID playerId,boolean isHost){
        this.name = name;
        this.playerId = playerId;
        this.isHost = isHost;


    }
    public void setRole(Role role){
        this.role = role;
    }

    public Role getRole() {
        return role;
    }

    public void setSessionUUID(UUID sessionUUID) {
        this.sessionUUID = sessionUUID;
    }

    public UUID getSessionUUID() {
        return sessionUUID;
    }

    public void setConnection(SseEmitter connection) {
        this.connection = connection;
    }

    public SseEmitter getConnection() {
        return connection;
    }

    public boolean isHost() {
        return isHost;
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
