package Creative.train.GameLogic.Items;

import Creative.train.DataTypes.Player;
import Creative.train.Managers.SessionManager;

import java.util.ArrayList;
import java.util.List;

public class Weapon extends Item{
    protected final int cooldownInSeconds;
    protected long cooldownEnd;
    public Weapon(String name,int cooldownInSeconds){
        super(name,new ArrayList<>(List.of("Weapon")));
        this.cooldownInSeconds = cooldownInSeconds;
    }
    public boolean killAbility(Player player,int killDelay) {
        if(System.currentTimeMillis()>=cooldownEnd) return false;
        try {
            Thread.sleep(killDelay);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
        SessionManager.getInstance().killPlayer(player);
        cooldownEnd = System.currentTimeMillis() + cooldownInSeconds * 1000L;
        return true;
    }
}
