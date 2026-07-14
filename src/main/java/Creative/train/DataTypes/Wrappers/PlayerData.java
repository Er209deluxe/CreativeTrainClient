package Creative.train.DataTypes.Wrappers;

import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.UUID;

public class PlayerData {
    public UUID playerUuid;
    public boolean isHost;
    public SseEmitter connection;
    public UUID sessionUuid;
    public String token;
    public String challenge;

}
