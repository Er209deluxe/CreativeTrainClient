package Creative.train.DataTypes;

import Creative.train.Backend.ExceptionTypes.InventoryFullException;
import Creative.train.Backend.ExceptionTypes.NotEnoughCoinsException;
import Creative.train.Backend.ExceptionTypes.NotFoundException;
import Creative.train.Backend.api.SseHandler;
import Creative.train.DataTypes.Wrappers.BasePlayerData;
import Creative.train.DataTypes.Wrappers.PlayerData;
import Creative.train.GameLogic.Items.Item;
import Creative.train.GameLogic.Roles.Role;
import Creative.train.Managers.EncryptionManager;
import Creative.train.Managers.SessionManager;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

public class Player {

    private final BasePlayerData baseData = new BasePlayerData();
    private final PlayerData data = new PlayerData();
    private final Item[] inventory = new Item[9];
    private int coins=0;
    private Quest currentQuest;
    public enum Quest{
        Homework,
        eat,
        drink
    }
    public Player(String name, UUID playerId,String passwordHash,boolean isHost){
        baseData.playerName = name;
        baseData.isAlive = true;
        data.playerUuid = playerId;
        data.isHost = isHost;
        data.token = passwordHash;
    }
    public void assignQuest(){
        if(currentQuest!=null){
            return;
        }
        List<Quest> values = Collections.unmodifiableList(Arrays.asList(Quest.values()));
        int ranInt = (int)(Math.random() * values.size());

        currentQuest = values.get(ranInt);
    }

    public BasePlayerData getBaseData() {
        return baseData;
    }

    public boolean isCorrectPass(String password){
        String hashedPassword = EncryptionManager.sha256(password);

        return data.token.equals(hashedPassword);
    }

    public Item[] getInventory() {
        return inventory;
    }

    /**
     * Adds item to player inventory, O(n)
     * @param item the item you want to add
     * @return true if item got added false if not
     */
    public boolean addItem(Item item){
        for(int i=0;i<inventory.length;i++){
            if(inventory[i]==null){
                inventory[i] = item;
                return true;
            }
        }
        return false;
    }
    public void removeItem(int slot){
        inventory[slot] = null;
    }
    public Item getItem(UUID itemUuid) {
        for (Item item : inventory) {
            if (item != null && item.getItemUuid().equals(itemUuid)) {
                return item;
            }
        }
        return null;
    }

    /**
     * Assigns a role if role has already been assigned do nothing
     */
    public void assignRole(Role role){
        if(baseData.role==null) {
            baseData.role = role;
        }
    }

    public int getCoins() {
        return coins;
    }

    public boolean buyItem(UUID itemUuid) throws NotFoundException,NotEnoughCoinsException,InventoryFullException {
        Item item;

        try {
            item = getRole().getItemShop().get(itemUuid).copy();
        } catch (Exception e) {
            throw new NotFoundException("Item", itemUuid);
        }

        if (getCoins() < item.getPrice()) {
            throw new NotEnoughCoinsException();
        }
        boolean didBuy = addItem(item);
        if (!didBuy) {
            throw new InventoryFullException();
        }

        changeCoins(-item.getPrice());
        return true;
    }
    public void changeCoins(int amount){
        coins+=amount;
        SseHandler.sendCoinUpdate(data.playerUuid,coins);
    }

    public void earnPassiveIncome(){
            int passiveIncome = SessionManager.getInstance().getSession(getSessionUUID()).getGeneralConfig().getPassiveIncome();
            changeCoins(passiveIncome);
    }
    public Role getRole() {
        return baseData.role;
    }

    public void setSessionUUID(UUID sessionUUID) {
        data.sessionUuid = sessionUUID;
    }

    public UUID getSessionUUID() {
        return data.sessionUuid;
    }

    public void setConnection(SseEmitter connection) {
        data.connection = connection;
    }

    public SseEmitter getConnection() {
        return data.connection;
    }

    public boolean isHost() {
        return data.isHost;
    }

    public String getName() {
        return baseData.playerName;
    }

    public UUID getPlayerId() {
        return data.playerUuid;
    }
    public void setAlive(boolean alive){
        baseData.isAlive=alive;
    }

    public boolean isAlive() {
        return baseData.isAlive;
    }
}
