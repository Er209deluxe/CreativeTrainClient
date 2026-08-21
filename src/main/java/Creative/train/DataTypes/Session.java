package Creative.train.DataTypes;

import Creative.train.Backend.ExceptionTypes.UserAlreadyInSessionExcepion;
import Creative.train.Backend.ExceptionTypes.UsernameAlreadyExistsException;
import Creative.train.GameLogic.GeneralConfig;
import Creative.train.GameLogic.Roles.LicensedVillain;
import Creative.train.GameLogic.Roles.Role;
import Creative.train.Managers.QuestManager;
import Creative.train.Managers.TimeManager;
import Creative.train.Managers.SessionManager;

import java.util.*;
import java.util.stream.Collectors;

public class Session {

    private GeneralConfig generalConfig;

    private int aliveCivilians;
    private int aliveKillers;
    private int aliveNeutrals;

    private boolean active = false;
    private final UUID sessionId;
    private final Map<UUID,Player> playerMap = new HashMap<>();
    private final UUID hostUuid;

    private TimeManager timeManager;
    private QuestManager questManager;

    List<Role> endPreventingNeutrals = new ArrayList<>();

    public Session(UUID hostUuid){
        sessionId = UUID.randomUUID();
        this.hostUuid = hostUuid;
    }
    public Collection<Player> getAllPlayers(){
        return playerMap.values();
    }
    public void addPreventingNeutral(Role role){
            endPreventingNeutrals.add(role);
    }
    public void removePreventingNeutral(Role role){
        endPreventingNeutrals.remove(role);

    }


    public void incrementAliveCivilians(){
        aliveCivilians++;
    }

    public void incrementAliveKillers(){
        aliveKillers++;
    }
    public void decrementAliveNeutrals(){
        aliveNeutrals--;
    }
    public void incrementAliveNeutrals(){
        aliveNeutrals++;
    }
    public void decrementAlivePlayers(Player player){

        if(player.getRole().getRoleInfo().team().equals(Role.Team.CIVILIAN)){
            aliveCivilians--;
        }
        if(player.getRole().getRoleInfo().team().equals(Role.Team.KILLER)){
            aliveKillers--;
        }

        if (aliveCivilians <= 0 && aliveKillers <= 0) {

            for (Role role : endPreventingNeutrals) {
                if (role instanceof LicensedVillain) {
                    SessionManager.getInstance().endSession(
                            getSessionId(),
                            Role.Team.NEUTRAL,
                            "Licensed Villain is the last one standing"
                    );
                    return;
                }
            }
        }

        if(!endPreventingNeutrals.isEmpty()) return;

        if(aliveCivilians<=0) SessionManager.getInstance().endSession(getSessionId(), Role.Team.KILLER,"All Civilians died");
        if(aliveKillers<=0) SessionManager.getInstance().endSession(getSessionId(), Role.Team.CIVILIAN,"All Killers died");
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
    public void start(GeneralConfig generalConfig){
        active=true;
        this.generalConfig = generalConfig;
        questManager = new QuestManager(this);
        timeManager = new TimeManager(this,questManager);
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
