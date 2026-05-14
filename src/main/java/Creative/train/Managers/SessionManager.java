package Creative.train.Managers;

import Creative.train.Api.Backend.SseHandler;
import Creative.train.DataTypes.Player;
import Creative.train.DataTypes.RegisterPlayerResponse;
import Creative.train.DataTypes.RequestTypes.PlayerInformation;
import Creative.train.DataTypes.Session;
import Creative.train.GameLogic.RoleAssigner;
import org.springframework.http.ResponseEntity;

import java.util.*;

public class SessionManager {
    Map<UUID,Player> playerMap;
    private final Map<UUID, Session> activeSessions;
    private static final SessionManager sessionManager = new SessionManager();
    private SessionManager(){
        activeSessions = new HashMap<>();
        playerMap = new HashMap<>();
    }
    public Player getPlayer(UUID playerUuid){
        return playerMap.get(playerUuid);
    }
    public Map<UUID, Player> getPlayerMap() {
        return playerMap;
    }

    public static SessionManager getInstance() {
        return sessionManager;
    }

    public Session getSession(UUID uuid){
        return activeSessions.get(uuid);
    }
    public Session registerSession(UUID playerUuid){
        Session newSession = new Session(playerUuid);

        activeSessions.put(newSession.getSessionId(),newSession);
        return newSession;
    }
    public RegisterPlayerResponse registerPlayerToSession(UUID sessionUuid, Player player) {

        RegisterPlayerResponse response = new RegisterPlayerResponse();

        // 1. VALIDATION
        if (playerMap.containsKey(player.getPlayerId())) {
            return error(response, 409, "User already in a session");
        }

        if (!player.isHost() && !activeSessions.containsKey(sessionUuid)) {
            return error(response, 404, "Session not found");
        }

        // 2. ACTION
        if (player.isHost()) {
            return handleHost(player, response);
        }

        return handleJoin(sessionUuid, player, response);
    }
    private RegisterPlayerResponse error(RegisterPlayerResponse response, int code, String msg) {
        response.setResponse(ResponseEntity.status(code).body(msg));
        return response;

    }
    private RegisterPlayerResponse handleHost(Player player, RegisterPlayerResponse response) {

        Session newSession = registerSession(player.getPlayerId());

        if(!activeSessions.get(newSession.getSessionId()).addPlayer(player)){
            return error(response,409,"Username already joined");
        }

        playerMap.put(player.getPlayerId(), player);

        response.setPlayerInformation(
                new PlayerInformation(newSession.getSessionId(), player.getPlayerId())
        );
        response.setHost(true);
        return response;
    }

    private RegisterPlayerResponse handleJoin(UUID sessionUuid, Player player, RegisterPlayerResponse response) {

        Session session = activeSessions.get(sessionUuid);

        if(!session.addPlayer(player)){
            return error(response,409,"Username already joined");

        }
        playerMap.put(player.getPlayerId(), player);

        response.setPlayerInformation(new PlayerInformation(sessionUuid,player.getPlayerId()));
        response.setHost(false);
        return response;
    }
    public Player getHostUuid(UUID session){
        return getPlayer(activeSessions.get(session).getHostUuid());
    }

    /**
     *
     * @param sessionUuid sessionUuid
     * @return every username in session
     * @throws NullPointerException when no session is found
     */
    public Set<String> getAllNamesInSession(UUID sessionUuid){
        Session session = activeSessions.get(sessionUuid);
        if(session == null) return null;
        return session.getAllNames();
    }
    public List<UUID> getAllUuidsInSession(UUID sessionUuid){
        Session session = activeSessions.get(sessionUuid);
        if(session == null) return null;
        return session.getAllPlayerUuids();
    }
    public void removePlayer(UUID playerUuid){
        Player player =playerMap.get(playerUuid);
        if(player==null) return;
        UUID sessionUuid=player.getSessionUUID();

        playerMap.remove(playerUuid);
        Session session = activeSessions.get(sessionUuid);
        if(session==null) return;
        session.removePlayer(playerUuid);
        System.out.println("removed:"+playerUuid);
    }
    public void startSession(UUID sessionUuid){
        Session session = getSession(sessionUuid);

        RoleAssigner.assignAllRoles(session);

        session.start();

        SseHandler.sendSessionStart(getAllUuidsInSession(sessionUuid));
    }
    public boolean isSessionActive(UUID sessionUuid){
        return activeSessions.get(sessionUuid).isActive();
    }
    public void killPlayer(Player player){
        player.setAlive(false);
        SseHandler.sendDeathInfo(player.getPlayerId());
    }
}
