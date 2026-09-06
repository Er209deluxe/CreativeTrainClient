package Creative.train.DataTypes.Wrappers;

import Creative.train.DataTypes.Player;
import Creative.train.GameLogic.Items.Weapon;

public class KillInformation {
    private final Player victim;
    private final Player killer;
    private final Weapon item;
    private long expireTime;
    public KillInformation(Player killer, Player victim, Weapon item){
        this.killer = killer;
        this.victim = victim;
        this.item = item;
    }

    public void setExpireTime(long expireTime) {
        this.expireTime = expireTime;
    }

    public long getExpireTime() {
        return expireTime;
    }

    public Weapon getItem() {
        return item;
    }

    public Player getKiller() {
        return killer;
    }

    public Player getVictim() {
        return victim;
    }
}
