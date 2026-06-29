package Creative.train.DataTypes.Wrappers;

import Creative.train.GameLogic.Roles.Role;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.UUID;

public class PlayerData {
    public UUID playerId;
    public boolean isHost;
    public SseEmitter connection;
    public UUID sessionUUID;
    public String passwordHash;
}
