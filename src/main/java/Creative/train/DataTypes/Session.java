package Creative.train.DataTypes;

import Creative.train.Backend.ExceptionTypes.UserAlreadyInSessionExcepion;
import Creative.train.Backend.ExceptionTypes.UsernameAlreadyExistsException;
import Creative.train.GameLogic.GeneralConfig;
import Creative.train.GameLogic.Roles.Role;
import Creative.train.GameLogic.TimeManager;
import Creative.train.Managers.SessionManager;

import java.util.*;
import java.util.stream.Collectors;

public class Session {
    private GeneralConfig generalConfig=
            new GeneralConfig(
                    null,
                    50,
                    7,1,
                    50,
                    30);
    private int aliveCivilians;
    private int aliveKillers;
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

    public void setAliveCivilians(int aliveCivilians) {
        this.aliveCivilians = aliveCivilians;
    }

    public void setAliveKillers(int aliveKillers) {
        this.aliveKillers = aliveKillers;
    }

    public void decrementAlivePlayers(Player player){
        if(player.getRole().getTeam().equals(Role.Team.CIVILIAN)){
            aliveCivilians--;
            if(aliveCivilians<=0) SessionManager.getInstance().endSession(getSessionId(), Role.Team.KILLER,"All Civilians died");
            return;
        }
        if(player.getRole().getTeam().equals(Role.Team.KILLER)){
            aliveKillers--;
            if(aliveKillers<=0) SessionManager.getInstance().endSession(getSessionId(), Role.Team.CIVILIAN,"All Killers died");
        }
    }

    public GeneralConfig getGeneralConfig() {
        return generalConfig;
    }

    public void addPlayer(Player player){
        if(playerMap.containsKey(player.getPlayerId())) throw new UserAlreadyInSessionExcepion(player.getPlayerId()); // User already joined

        boolean nameExists = playerMap.values().stream()
                .anyMatch(p -> p.getName().equals(player.getName()));

        if(nameExists) throw new UsernameAlreadyExistsException(player.getName());

        playerMap.put(player.getPlayerId(), player);
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

    public TimeManager getTimeManager() {
        return timeManager;
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
