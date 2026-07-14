package Creative.train.DataTypes;

import Creative.train.Backend.ExceptionTypes.InventoryFullException;
import Creative.train.Backend.ExceptionTypes.NotEnoughCoinsException;
import Creative.train.Backend.ExceptionTypes.NotFoundException;
import Creative.train.Backend.api.SseHandler;
import Creative.train.DataTypes.Wrappers.BasePlayerData;
import Creative.train.DataTypes.Wrappers.PlayerData;
import Creative.train.GameLogic.GeneralConfig;
import Creative.train.GameLogic.Items.Item;
import Creative.train.GameLogic.Roles.Role;
import Creative.train.Managers.EncryptionManager;
import Creative.train.Managers.SessionManager;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class Player {

    private final BasePlayerData baseData = new BasePlayerData();
    private final PlayerData data = new PlayerData();
    private final Item[] inventory = new Item[9];
    private int coins=0;
    private Session session;
    private GeneralConfig sessionConfig;
    public Player(String name, UUID playerId,String passwordHash,boolean isHost){
        baseData.playerName = name;
        baseData.isAlive = true;

        data.playerUuid = playerId;
        data.isHost = isHost;
        data.token = passwordHash;

    }
    public boolean isCorrectChallenge(String challenge){
        return challenge.equals(data.challenge);
    }
    public BasePlayerData getBaseData() {
        return baseData;
    }
    public void generateNewChallenge(){
        data.challenge = EncryptionManager.generateRandomBytes(16);
        SseHandler.sendChallengeUpdate(getPlayerId(),data.challenge);
    }
    public boolean isCorrectPass(String password){
        String hashedPassword = EncryptionManager.sha256(password);

        return data.token.equals(hashedPassword);
    }
    public void handleSanity(){
        if(!isAlive()) return;
        if(baseData.depression==-1){
            baseData.depression = sessionConfig.getBaseDepression();
            baseData.sanity = sessionConfig.getBaseSanity();
        }
        Map<String,Double> sanityData = new HashMap<>();

        if(baseData.sanity<=0){
            baseData.depression--;
            if(baseData.depression<=0){
                SessionManager.getInstance().setPlayerDead(this);
            }
            sanityData.put("sanity",(((double)baseData.sanity/(double)sessionConfig.getBaseSanity())));
            sanityData.put("depression",((double)(baseData.depression/(double)sessionConfig.getBaseDepression())));
            SseHandler.sendSanityUpdate(getPlayerId(),sanityData);
            return;
        }
        baseData.sanity--;
        if(baseData.depression<sessionConfig.getBaseDepression()){
            baseData.depression++;
        }
        sanityData.put("sanity",(((double)baseData.sanity/(double) sessionConfig.getBaseSanity())));
        sanityData.put("depression",((double)(baseData.depression/(double)sessionConfig.getBaseDepression())));
        SseHandler.sendSanityUpdate(getPlayerId(),sanityData);
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
        session = SessionManager.getInstance().getSession(getSessionUUID());
        sessionConfig = session.getGeneralConfig();

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
