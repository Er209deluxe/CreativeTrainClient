package Creative.train.Managers;

import Creative.train.DataTypes.Player;
import Creative.train.DataTypes.Session;
import Creative.train.ResponseFormatter;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class SessionManager {
    private final Map<UUID, Session> activeSessions;
    private static final SessionManager sessionManager = new SessionManager();
    private SessionManager(){
        activeSessions = new HashMap<>();
    }

    public static SessionManager getInstance() {
        return sessionManager;
    }

    public Session getSession(UUID uuid){
        return activeSessions.get(uuid);
    }
    public void registerSession(Session session){
        activeSessions.put(session.getSessionId(),session);
    }
    public String registerPlayerToSession(UUID sessionUuid,Player player){
        if(!activeSessions.containsKey(sessionUuid)){
            return ResponseFormatter.buildResponse(404,"Session not found","");
        }
        activeSessions.get(sessionUuid).addPlayer(player);
        return ResponseFormatter.buildResponse(200,"OK","");
    }

}
