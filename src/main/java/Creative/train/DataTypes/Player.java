package Creative.train.DataTypes;

import Creative.train.Backend.ExceptionTypes.InventoryFullException;
import Creative.train.Backend.ExceptionTypes.NotEnoughCoinsException;
import Creative.train.Backend.ExceptionTypes.NotFoundException;
import Creative.train.Backend.api.SseHandler;
import Creative.train.DataTypes.Wrappers.BasePlayerData;
import Creative.train.DataTypes.Wrappers.DeathInformation;
import Creative.train.DataTypes.Wrappers.DroppedItem;
import Creative.train.DataTypes.Wrappers.PlayerData;
import Creative.train.GameLogic.Items.Item;
import Creative.train.GameLogic.Quest;
import Creative.train.GameLogic.Roles.Amnesiac;
import Creative.train.GameLogic.Roles.Role;
import Creative.train.Managers.EncryptionManager;
import Creative.train.Managers.SessionManager;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.lang.reflect.InvocationTargetException;
import java.util.*;

public class Player {

    private final BasePlayerData baseData = new BasePlayerData();
    private final PlayerData data = new PlayerData();

    private final List<DroppedItem> droppedItems = new ArrayList<>();
    private final Item[] inventory = new Item[9];

    private int coins=0;
    private Quest currentQuest;

    private Session session;

    public Player(String name, UUID playerId,String passwordHash,boolean isHost){
        baseData.playerName = name;
        baseData.isAlive = true;

        data.playerUuid = playerId;
        data.isHost = isHost;
        data.token = passwordHash;
    }
    public boolean hasItem(Class<? extends Item> itemType) {
        for (Item item : inventory) {
            if (itemType.isInstance(item)) {
                return true;
            }
        }
        return false;
    }

    public boolean dropItem(DroppedItem itemDrop) {
        Item item = itemDrop.getItem();

        for (int i = 0; i < inventory.length; i++) {
            if (inventory[i] == item) {
                inventory[i] = null;
                droppedItems.add(itemDrop);
                return true;
            }
        }

        return false;
    }


    public List<DroppedItem> getItemDrops() {
        return droppedItems;
    }

    public boolean completeQuest(String questToken) {
        if (currentQuest == null || !currentQuest.getQuestToken().equals(questToken)) {
            return false;
        }

        currentQuest = null;

        restoreSanityAfterQuest();
        changeCoins(getRole().getTaskIncome());

        return true;
    }
    private void restoreSanityAfterQuest() {
        int maxSanity = session.getGeneralConfig().getBaseSanity();

        int newSanity = getBaseData().sanity + maxSanity / 2;

        if (newSanity > maxSanity * 0.75) {
            newSanity = maxSanity;
        }

        updateSanity(newSanity, getBaseData().depression);
    }
    public boolean assignQuest(Quest newQuest){
        if(currentQuest!=null){
            return false;
        }
        currentQuest = newQuest;
        SseHandler.sendNewQuestUpdate(getPlayerId(),currentQuest.getDescription());
        return true;
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
    public Role changeRole(String roleName) throws NoSuchMethodException, InvocationTargetException, InstantiationException, IllegalAccessException {
        if(getRole() instanceof Amnesiac){
            session.decrementAliveNeutrals();
            baseData.role = Objects.requireNonNull(GlobalVariableHolder.getRoleClass(roleName)).getDeclaredConstructor(UUID.class).newInstance(getSessionUUID());
            return baseData.role;
        }
        return null;
    }

    public void handleSanity(){
        if(!isAlive()) return;
        if(getBaseData().depression==-1){
            getBaseData().depression = session.getGeneralConfig().getBaseDepression();
            getBaseData().sanity = session.getGeneralConfig().getBaseSanity();
        }

        if(getBaseData().sanity<=0){
            updateSanity(getBaseData().sanity, getBaseData().depression-1);
            if(getBaseData().depression<=0){
                DeathInformation information = new DeathInformation(this, DeathInformation.reason.depression);
                SessionManager.getInstance().setPlayerDead(information);
            }
            return;
        }
        int sanity=getBaseData().sanity-1;
        int depression=getBaseData().depression;

        if(getBaseData().depression<session.getGeneralConfig().getBaseDepression()){
            depression++;
        }
        updateSanity(sanity,depression);
    }

    public void updateSanity(int sanityValue,int depressionValue){
        Map<String,Double> sanityData = new HashMap<>();

        getBaseData().sanity = sanityValue;
        getBaseData().depression = depressionValue;

        sanityData.put("sanity",(((double)sanityValue/(double) session.getGeneralConfig().getBaseSanity())));
        sanityData.put("depression",((double)(depressionValue/(double)session.getGeneralConfig().getBaseDepression())));
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
    public void removeItem(Item item){
        for (int i=0;i<inventory.length;i++) {
            if (inventory[i] != null && inventory[i].equals(item)) {
                inventory[i] = null;
                return;
            }
        }
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
            List<Item> baseInv = baseData.role.getBaseInventory();
            if(baseInv!=null) {
                baseInv.forEach(this::addItem);
            }
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
    public void triggerDeath() {
        baseData.isAlive = false;

        for (int i = 0; i < inventory.length; i++) {
            Item item = inventory[i];

            if (item != null && item.isDropOnDeath()) {
                droppedItems.add(new DroppedItem(this, item));
                inventory[i] = null;
            }
        }
    }

    public void setAlive(){
        baseData.isAlive = true;
    }

    public boolean isAlive() {
        return baseData.isAlive;
    }
}
