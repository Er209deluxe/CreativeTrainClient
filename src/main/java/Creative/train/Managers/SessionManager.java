package Creative.train.Managers;

import Creative.train.Backend.ExceptionTypes.NotFoundException;
import Creative.train.Backend.ExceptionTypes.UserAlreadyInSessionExcepion;
import Creative.train.Backend.api.SseHandler;
import Creative.train.ConfigManagement.RoleLoader;
import Creative.train.DataTypes.Player;
import Creative.train.DataTypes.Wrappers.BasePlayerData;
import Creative.train.DataTypes.Wrappers.PlayerData;
import Creative.train.DataTypes.Session;
import Creative.train.DataTypes.Wrappers.SessionEndData;
import Creative.train.GameLogic.Items.Item;
import Creative.train.GameLogic.Items.Weapon;
import Creative.train.GameLogic.RoleAssigner;
import Creative.train.GameLogic.Roles.Role;
import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.io.IOException;
import java.util.*;

public class SessionManager {
    private final Map<UUID,Player> playerMap;
    private final Map<UUID, Session> sessions;
    private static final SessionManager sessionManager = new SessionManager();
    private SessionManager(){
        sessions = new HashMap<>();
        playerMap = new HashMap<>();
    }
    public Player getPlayer(UUID playerUuid){
        return playerMap.get(playerUuid);
    }

    public static SessionManager getInstance() {
        return sessionManager;
    }

    public Session getSession(UUID uuid){
        return sessions.get(uuid);
    }
    public Session registerSession(UUID playerUuid){
        Session newSession = new Session(playerUuid);

        sessions.put(newSession.getSessionId(),newSession);
        return newSession;
    }
    public void addPlayer(Session session,Player player) throws NotFoundException {

        if (getPlayer(player.getPlayerId())!=null) {
            throw new UserAlreadyInSessionExcepion(player.getPlayerId());
        }

        if (!player.isHost() && getSession(session.getSessionId())==null) {
            throw new NotFoundException("Session",session.getSessionId());
        }
        session.addPlayer(player);

        playerMap.put(player.getPlayerId(),player);
    }

    public PlayerData registerPlayerToSession(UUID sessionUuid, Player player,String token) throws NotFoundException {

        Session session = getSession(sessionUuid);
        if (session == null&&!player.isHost()) {
            throw new NotFoundException("Session",sessionUuid);
        }
        if (player.isHost()) {
            session = registerSession(player.getPlayerId());
            System.out.println("Hostuuid: "+session.getHostUuid());
        }
        addPlayer(session,player);

        PlayerData playerData = new PlayerData();
        playerData.sessionUuid = session.getSessionId();
        playerData.playerUuid = player.getPlayerId();
        playerData.token = token;
        playerData.isHost = player.isHost();
        return playerData;
    }


    public Player getHostUuid(UUID sessionUuid) throws NotFoundException {
        Session session = getSession(sessionUuid);
        if (session == null) throw new NotFoundException("Session",sessionUuid);

        UUID hostUuid = session.getHostUuid();
        if (hostUuid == null) return null;

        return getPlayer(hostUuid);
    }
    /**
     *
     * @param sessionUuid sessionUuid
     * @return every username in session
     * @throws NullPointerException when no session is found
     */
    public Set<String> getAllNamesInSession(UUID sessionUuid){
        Session session = getSession(sessionUuid);
        if(session == null) return null;
        return session.getAllNames();
    }
    public List<UUID> getAllUuidsInSession(UUID sessionUuid){
        Session session = getSession(sessionUuid);
        if(session == null) return null;
        return session.getAllPlayerUuids();
    }
    public void removePlayer(UUID playerUuid){
        Player player =getPlayer(playerUuid);
        if(player==null) return;
        UUID sessionUuid=player.getSessionUUID();

        playerMap.remove(playerUuid);
        Session session = getSession(sessionUuid);
        if(session==null) return;
        session.removePlayer(playerUuid);
        System.out.println("removed:"+playerUuid);
    }
    public boolean startSession(UUID sessionUuid,JsonNode json) {
        Session session = getSession(sessionUuid);

        if(!roleLoader(json,sessionUuid)) return false;

        RoleAssigner.assignAllRoles(session);

        session.start();

        SseHandler.sendSessionStart(getAllUuidsInSession(sessionUuid));
        return true;
    }
    public void endSession(UUID sessionUuid, Role.Team winners,String reason){
        SessionEndData sessionEndData = new SessionEndData();
        Session session = getSession(sessionUuid);
        session.stop();

        sessionEndData.winnerTeam = winners;
        sessionEndData.reason = reason;

        List<BasePlayerData> playerEndScreenInfoList = new ArrayList<>();
        List<UUID> playerUuids=session.getAllPlayerUuids();
        for(UUID playerUuid : playerUuids){
            Player player = SessionManager.getInstance().getPlayer(playerUuid);
            playerEndScreenInfoList.add(player.getBaseData());
        }

        sessionEndData.playerDataList = playerEndScreenInfoList;
        SseHandler.sendSessionEnd(playerUuids,sessionEndData);

        removeSession(session);

    }
    private void removeSession(Session session){
        session.getAllPlayerUuids().forEach(this::removePlayer);
        sessions.remove(session.getSessionId());
    }
    public static boolean roleLoader(JsonNode json, UUID sessionUuid){
        RoleLoader loader = new RoleLoader();
        try {
            loader.load(json, sessionUuid);
        } catch (IOException e){
            //failed to parse json
            return false;
        }
        return true;
    }
    public boolean isSessionActive(UUID sessionUuid){
        return getSession(sessionUuid).isActive();
    }
    public void setPlayerDead(Player player){
        player.setAlive(false);
        SseHandler.sendDeathInfo(player.getPlayerId());

        Session session = getSession(player.getSessionUUID());
        session.decrementAlivePlayers(player);
        session.getTimeManager().changeRemainingSecondsBy
                (session.getGeneralConfig().getIncrementTimerOnKillInSeconds());
    }
    public ResponseEntity<?> killPlayer(Player killer, Player victim, UUID itemUuid){
        Session session = getSession(killer.getSessionUUID());
        if(!isSessionActive(killer.getSessionUUID())) return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body("Session is not active");
        if(!killer.isAlive()) return ResponseEntity.status(HttpStatus.CONFLICT).body("You are not alive");
        if(!victim.isAlive()) return ResponseEntity.status(HttpStatus.CONFLICT).body("Victim is already dead");

        Item item = killer.getItem(itemUuid);
        if(item==null) return ResponseEntity.status(HttpStatus.CONFLICT).body("Item does not exist");

        if(item instanceof Weapon weapon){
            if(!weapon.killAbility(victim)){
             return ResponseEntity.status(HttpStatus.CONFLICT).body("Weapon is still on cooldown");
            }
            if(killer.getRole().getTeam().equals(Role.Team.KILLER)) {
                killer.changeCoins(session.getGeneralConfig().getKillReward());
            }
            setPlayerDead(victim);
            return ResponseEntity.status(HttpStatus.OK).build();
        }
        return ResponseEntity.status(HttpStatus.CONFLICT).body("Item is not a Weapon");
    }
}
