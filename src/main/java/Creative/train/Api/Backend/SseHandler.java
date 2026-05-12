package Creative.train.Api.Backend;

import Creative.train.DataTypes.Player;
import Creative.train.DataTypes.Session;
import Creative.train.GameLogic.Roles.Role;
import Creative.train.Managers.SessionManager;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.*;

public class SseHandler {
    //private final Map<UUID, Player> connectionMap;
    private final static SseHandler INSTANCE = new SseHandler();
    private SseHandler(){
    }
    public static SseHandler getInstance(){
        return INSTANCE;
    }

    public SseEmitter stream(UUID playerUUID) {
        SseEmitter emitter = new SseEmitter(0L); // no timeout

        System.out.println("Player UUID: " + playerUUID + " connected.");
        handleNewConnection(playerUUID, emitter);

        emitter.onCompletion(() -> {
            System.out.println("Connection closed for player UUID: " + playerUUID);
        });
        emitter.onTimeout(() -> {
            System.out.println("Connection timed out for player UUID: " + playerUUID);
        });
        emitter.onError((e) -> {
            System.out.println("Error occurred for player UUID: " + playerUUID);
        });

        return emitter;
    }
    private void handleNewConnection(UUID playerUuid,SseEmitter emitter){
        Player player = SessionManager.getInstance().getPlayer(playerUuid);
        if (player == null) {
            //emitter.completeWithError(new RuntimeException("Player not found"));
            return;
        }
        player.setConnection(emitter);
    }
    public static void sendNewPlayerInfo(List<UUID> playerUuids, String player) {
       sendPlayer(playerUuids,"playerJoined",player);
    }
    public static void sendDeathInfo(UUID playerUuid) {
        sendPlayer(List.of(playerUuid),"deathEvent","");
    }
    public static void sendSessionStart(List<UUID> playerUuids) {
        for (UUID playerUuid : playerUuids) {
            Player player = SessionManager.getInstance().getPlayer(playerUuid);
            sendPlayer(new ArrayList<>(List.of(player.getPlayerId())),"sessionStart",player.getRole());
        }
    }

    public static void sendPlayerDisconnectInfo(List<UUID> playerUuids,String player){
        sendPlayer(playerUuids,"playerDisconnected",player);
    }
    private static void sendPlayer(List<UUID> playerUuids,String event,Object data){
        Iterator<UUID> iterator = playerUuids.iterator();
        while (iterator.hasNext()) {
            UUID id = iterator.next();
            Player playerData = SessionManager.getInstance().getPlayer(id);
            SseEmitter emitter = playerData.getConnection();

            if (emitter == null) continue;

            try {
                emitter.send(SseEmitter.event()
                        .name(event)
                        .data(data));

            } catch (IOException e) {
                iterator.remove();
                sendPlayerDisconnectInfo(playerUuids, playerData.getName());
            }
        }
    }
    public static void disconnectPlayer(UUID playerUuid){
        SessionManager sm = SessionManager.getInstance();
        Player player = sm.getPlayer(playerUuid);

        if (player == null) return;

        Session session = sm.getSession(player.getSessionUUID());
        List<UUID> players = new ArrayList<>(session.getAllPlayerUuids());

        players.remove(playerUuid);

        sendPlayerDisconnectInfo(players, player.getName());

        SseEmitter emitter = player.getConnection();
        if (emitter != null) {
            try {
                emitter.complete();
            } catch (IllegalStateException ignored) {}
        }

        sm.removePlayer(playerUuid);
    }

    }

