package Creative.train.DataTypes.Wrappers;

import Creative.train.DataTypes.Player;
import Creative.train.GameLogic.Items.Weapon;

public class DeathInformation {
    private final Player victim;
    private final Player killer;
    private final Weapon item;
    private long expireTime;
    private final reason deathReason;

    public enum reason{
        kill,
        depression,
        failedItemTransfer
    }

    public DeathInformation(Player killer, Player victim, Weapon item){
        this.killer = killer;
        this.victim = victim;
        this.item = item;
        deathReason = reason.kill;
    }
    public DeathInformation(Player victim,reason deathReason){
        this.victim = victim;
        killer = null;
        item = null;

        this.deathReason = deathReason;
    }

    public reason getDeathReason() {
        return deathReason;
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
