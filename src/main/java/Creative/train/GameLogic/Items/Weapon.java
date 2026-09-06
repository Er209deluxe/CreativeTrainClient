package Creative.train.GameLogic.Items;

import Creative.train.DataTypes.Wrappers.KillInformation;
import Creative.train.Managers.SessionManager;
import Creative.train.Managers.ThreadManager;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class Weapon extends Item{
    protected final int cooldownInSeconds;
    protected long cooldownEnd;
    protected int killDelay=0;
    public Weapon(String name,int cooldownInSeconds,int killDelay){
        super(name,new ArrayList<>(List.of("Weapon")));
        this.cooldownInSeconds = cooldownInSeconds;
    }
    public boolean isOnCooldown(){
        return System.currentTimeMillis() >= cooldownEnd;
    }

    public void killAbility(KillInformation information) {
        cooldownEnd = System.currentTimeMillis() + cooldownInSeconds * 1000L;

        ThreadManager.getScheduler().schedule(() -> {
            SessionManager.getInstance().setPlayerDead(information);
        }, killDelay, TimeUnit.SECONDS);

    }
}
