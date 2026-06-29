package Creative.train.DataTypes;

import Creative.train.GameLogic.RoleAssigner;
import Creative.train.GameLogic.TimeManager;

import java.util.*;
import java.util.stream.Collectors;

public class Session {
    private boolean active = false;
    private final UUID sessionId;
    private final Map<UUID,Player> playerMap = new HashMap<>();
    private final UUID hostUuid;
    private final int baseTimerMins=0;
    private final int baseTimerSecs=10;
    private final TimeManager timeManager = new TimeManager(this);
    public Session(UUID hostUuid){
        sessionId = UUID.randomUUID();
        this.hostUuid = hostUuid;
    }

    public int getBaseTimer() {
        return baseTimerMins * 60 + baseTimerSecs;
    }


    public boolean addPlayer(Player player){
        if(playerMap.containsKey(player.getPlayerId())) return false;

        boolean nameExists = playerMap.values().stream()
                .anyMatch(p -> p.getName().equals(player.getName()));

        if(nameExists) return false;

        playerMap.put(player.getPlayerId(), player);
        return true;
    }

    public UUID getSessionId() {
        return sessionId;
    }


    public UUID getHostUuid() {
        return hostUuid;
    }
    public List<UUID> getAllPlayerUuids(){
        return new ArrayList<>(playerMap.keySet());
    }
    public void removePlayer(UUID playerUuid){
        playerMap.remove(playerUuid);
    }
    public Set<String> getAllNames(){
        return playerMap.values().stream()
                .map(Player::getName)
                .collect(Collectors.toSet());
    }
    public void start(){
        active=true;
        timeManager.startCountdown();
    }
    public void stop(){
        active=false;
        timeManager.stopCountdown();
    }
    public boolean isActive() {
        return active;
    }
}
