package Creative.train.GameLogic.Items;

import Creative.train.DataTypes.Player;
import Creative.train.DataTypes.Wrappers.DeathInformation;
import Creative.train.Managers.SessionManager;
import Creative.train.Managers.ThreadManager;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class Weapon extends Item{
    protected final int cooldownInSeconds;
    protected long cooldownEnd;
    protected int killDelay=20;
    public Weapon(String name,int cooldownInSeconds,int killDelay){
        super(name,new ArrayList<>(List.of("Weapon")));
        this.cooldownInSeconds = cooldownInSeconds;
    }

    public boolean killAbility(DeathInformation information) {
        if (System.currentTimeMillis() < cooldownEnd) {
            return false;
        }

        cooldownEnd = System.currentTimeMillis() + cooldownInSeconds * 1000L;

        ThreadManager.getScheduler().schedule(() -> {
            SessionManager.getInstance().setPlayerDead(information);
        }, killDelay, TimeUnit.SECONDS);

        return true;
    }
    private void killPlayer(Player player){
        player.setAlive(false);

    }
}
