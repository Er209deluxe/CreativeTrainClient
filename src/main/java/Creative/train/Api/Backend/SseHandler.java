package Creative.train.Api.Backend;

import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class SseHandler {
    private final Map<UUID,SseEmitter> connectionMap = new HashMap<>();
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

        emitter.onCompletion(() -> {
            connectionMap.remove(playerUUID);
            System.out.println("Connection closed for player UUID: " + playerUUID);
        });
        emitter.onTimeout(() -> {
            connectionMap.remove(playerUUID);
            System.out.println("Connection timed out for player UUID: " + playerUUID);
        });
        emitter.onError((e) -> {
            connectionMap.remove(playerUUID);
            System.out.println("Error occurred for player UUID: " + playerUUID);
        });

        return emitter;
    }
    private void handleNewConnection(UUID playerUUID,SseEmitter emitter){
        connectionMap.put(playerUUID,emitter);
    }
    public void sendNewPlayerInfo(List<UUID> playerUuids, String player) {
        System.out.println("uuid size:"+playerUuids.size());
        for (UUID id : playerUuids) {
            System.out.println("id:"+id);
            SseEmitter emitter = connectionMap.get(id);

            if (emitter == null) {System.out.println("continue"); continue;}

            try {
                emitter.send(SseEmitter.event()
                        .name("playerJoined")
                        .data(player));
                System.out.println("sent playerjoined to:"+id);
            } catch (IOException e) {
                System.out.println("removed id  :"+id);

                connectionMap.remove(id);
            }
        }
    }
}
