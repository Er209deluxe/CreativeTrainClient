package Creative.train.GameLogic.Roles;

import Creative.train.Api.Backend.SseHandler;
import Creative.train.DataTypes.GlobalVariableHolder;
import Creative.train.DataTypes.Player;
import Creative.train.DataTypes.Session;

public class Killer extends Role{

    public Killer() {
        super("Killer", Team.KILLER);
    }
    public void killPlayer(Session session, Player player){
        player.setAlive(false);
        SseHandler.sendDeathInfo(player.getPlayerId());
    }
}
