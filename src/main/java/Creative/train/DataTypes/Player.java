package Creative.train.DataTypes;

import Creative.train.DataTypes.Wrappers.BasePlayerData;
import Creative.train.DataTypes.Wrappers.PlayerData;
import Creative.train.GameLogic.Items.Item;
import Creative.train.GameLogic.Roles.Innocent;
import Creative.train.GameLogic.Roles.Killer;
import Creative.train.GameLogic.Roles.Role;
import Creative.train.Managers.EncryptionManager;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.UUID;

public class Player {
    private final BasePlayerData baseData = new BasePlayerData();
    private final PlayerData data = new PlayerData();
    private final Item[] inventory = new Item[9];

    public Player(String name, UUID playerId,String passwordHash,boolean isHost){
        baseData.name = name;
        baseData.isAlive = true;
        data.playerId = playerId;
        data.isHost = isHost;
        data.passwordHash = passwordHash;

    }

    public BasePlayerData getBaseData() {
        return baseData;
    }

    public boolean isCorrectPass(String password){
        String hashedPassword = EncryptionManager.sha256(password);

        return data.passwordHash.equals(hashedPassword);
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
    public Item getItemFromSlot(int slot){
        return inventory[slot];
    }
    public void setRole(Role role){
        baseData.role = role;
    }

    public Role getRole() {
        return baseData.role;
    }

    public void setSessionUUID(UUID sessionUUID) {
        data.sessionUUID = sessionUUID;
    }

    public UUID getSessionUUID() {
        return data.sessionUUID;
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
        return baseData.name;
    }

    public UUID getPlayerId() {
        return data.playerId;
    }
    public void setAlive(boolean alive){
        baseData.isAlive=alive;
    }

    public boolean isAlive() {
        return baseData.isAlive;
    }
}
