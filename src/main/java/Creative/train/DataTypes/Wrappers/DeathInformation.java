package Creative.train.DataTypes.Wrappers;

import Creative.train.DataTypes.Player;
import Creative.train.GameLogic.Items.Item;

public class DeathInformation {
    private final Player victim;
    private final Player killer;
    private final Item item;

    public DeathInformation(Player killer,Player victim, Item item){
        this.killer = killer;
        this.victim = victim;
        this.item = item;
    }

    public Item getItem() {
        return item;
    }

    public Player getKiller() {
        return killer;
    }

    public Player getVictim() {
        return victim;
    }
}
