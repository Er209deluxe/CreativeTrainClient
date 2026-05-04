package Creative.train.Api.Backend;

import Creative.train.DataTypes.Player;
import Creative.train.DataTypes.Session;
import Creative.train.Managers.SessionManager;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

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

        try {
            emitter.send("connected");
            System.out.println("Sent 'connected' to player UUID: " + playerUUID);
        } catch (IOException e) {
            emitter.complete();
            System.out.println("Error sending message to player UUID: " + playerUUID);
        }
        SessionManager sessionManager= SessionManager.getInstance();
        emitter.onCompletion(() -> {
            sessionManager.removePlayer(playerUUID);
            System.out.println("Connection closed for player UUID: " + playerUUID);
        });
        emitter.onTimeout(() -> {
            sessionManager.removePlayer(playerUUID);
            System.out.println("Connection timed out for player UUID: " + playerUUID);
        });
        emitter.onError((e) -> {
            sessionManager.removePlayer(playerUUID);
            System.out.println("Error occurred for player UUID: " + playerUUID);
        });

        return emitter;
    }
    private void handleNewConnection(UUID playerUuid,SseEmitter emitter){
        //connectionMap.put(player.getPlayerId(),player);
        Player player = SessionManager.getInstance().getPlayer(playerUuid);
        if (player == null) {
            emitter.completeWithError(new RuntimeException("Player not found"));
            return;
        }
        player.setConnection(emitter);
    }
    public void sendNewPlayerInfo(List<UUID> playerUuids, String player) {
        System.out.println("uuid size:"+playerUuids.size());
        for (UUID id : playerUuids) {
            System.out.println("id:"+id);
            SseEmitter emitter = SessionManager.getInstance().getPlayer(id).getConnection();

            if (emitter == null) {System.out.println("continue"); continue;}

            try {
                emitter.send(SseEmitter.event()
                        .name("playerJoined")
                        .data(player));
                System.out.println("sent playerjoined to:"+id);
            } catch (IOException e) {
                System.out.println("removed id  :"+id);

                emitter.complete();
            }
        }
    }
    public void disconnectPlayer(UUID playerUuid){
        SessionManager.getInstance().getPlayer(playerUuid).getConnection().complete();
    }
}
