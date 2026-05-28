package Creative.train.GameLogic.Roles;

import Creative.train.Backend.api.SseHandler;
import Creative.train.DataTypes.Player;
import Creative.train.DataTypes.Session;

import java.util.UUID;

public class Killer extends Role{

    public Killer(UUID sessionUuid) {
        super( sessionUuid,"Killer");
    }
    public void killPlayer(Session session, Player player){
        player.setAlive(false);
        SseHandler.sendDeathInfo(player.getPlayerId());
    }
}
