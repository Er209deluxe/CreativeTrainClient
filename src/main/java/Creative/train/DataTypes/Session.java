package Creative.train.DataTypes;

import Creative.train.GameLogic.GeneralConfig;
import Creative.train.GameLogic.RoleAssigner;
import Creative.train.GameLogic.TimeManager;

import java.util.*;
import java.util.stream.Collectors;

public class Session {
    private GeneralConfig generalConfig=new GeneralConfig(null,50,3,30);

    private boolean active = false;
    private final UUID sessionId;
    private final Map<UUID,Player> playerMap = new HashMap<>();
    private final UUID hostUuid;

    private TimeManager timeManager;
    public Session(UUID hostUuid){
        sessionId = UUID.randomUUID();
        this.hostUuid = hostUuid;
    }
    public Collection<Player> getAllPlayers(){
        return playerMap.values();
    }

    public GeneralConfig getGeneralConfig() {
        return generalConfig;
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
        timeManager = new TimeManager(this);
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
