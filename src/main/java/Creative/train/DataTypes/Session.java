package Creative.train.DataTypes;

import java.util.*;
import java.util.stream.Collectors;

public class Session {
    private boolean active;
    private final UUID sessionId;
    private final Map<UUID,Player> playerMap = new HashMap<>();
    private final UUID hostUuid;
    public Session(UUID hostUuid){
        sessionId = UUID.randomUUID();
        this.hostUuid = hostUuid;
    }

    public void setActive() {
        this.active = true;
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

    public Map<UUID,Player> getPlayerMap() {
        return playerMap;
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
}
