package Creative.train.DataTypes.Wrappers;

import Creative.train.Backend.api.SseHandler;
import Creative.train.DataTypes.Player;
import Creative.train.GameLogic.Items.Item;
import Creative.train.Managers.SessionManager;
import Creative.train.Managers.TimeManager;
import com.fasterxml.jackson.annotation.JsonIgnore;

public class DroppedItem {
    @JsonIgnore
    private final Player itemHolder;
    @JsonIgnore
    private final TimeManager timeManager;
    private int countdown;
    private final Item item;

    public DroppedItem(Player itemHolder, Item item, int countdown){
        this.itemHolder = itemHolder;
        this.item = item;
        this.countdown = countdown;

        timeManager = SessionManager.getInstance().getSession(itemHolder.getSessionUUID()).getTimeManager();
        timeManager.addDecrementItem(this);

    }
    public DroppedItem(Player itemHolder, Item item){
        this.itemHolder = itemHolder;
        this.item = item;
        timeManager = null;
    }

    public Item getItem() {
        return item;
    }

    public int getCountdown() {
        return countdown;
    }

    public Player getItemHolder() {
        return itemHolder;
    }
    public void decrementCountdown(){
        if(timeManager==null) return;
        countdown--;
        if(countdown<=0){
            DeathInformation deathInformation = new DeathInformation(itemHolder, DeathInformation.reason.failedItemTransfer);
            SessionManager.getInstance().setPlayerDead(deathInformation);
            timeManager.removeDecrementItem(this);
            return;
        }
        SseHandler.sendDroppedItems(itemHolder.getPlayerId(),itemHolder.getItemDrops());
    }
}
