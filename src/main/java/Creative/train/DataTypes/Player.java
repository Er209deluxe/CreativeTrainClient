package Creative.train.DataTypes;

import Creative.train.GameLogic.Items.Item;
import Creative.train.GameLogic.Roles.Innocent;
import Creative.train.GameLogic.Roles.Killer;
import Creative.train.GameLogic.Roles.Role;
import Creative.train.Managers.EncryptionManager;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.UUID;

public class Player {
    private boolean isAlive=true;
    private final String name;
    private final UUID playerId;
    private final boolean isHost;
    private SseEmitter connection;
    private UUID sessionUUID;
    private Role role;
    private String passwordHash;
    Item[] inventory = new Item[9];
    public Player(String name, UUID playerId,String passwordHash,boolean isHost){
        this.name = name;
        this.playerId = playerId;
        this.isHost = isHost;
        this.passwordHash = passwordHash;

    }

    public boolean isCorrectPass(String password){
        String hashedPassword = EncryptionManager.sha256(password);

        return passwordHash.equals(hashedPassword);
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
        this.role = role;
    }

    public Role getRole() {
        return role;
    }

    public void setSessionUUID(UUID sessionUUID) {
        this.sessionUUID = sessionUUID;
    }

    public UUID getSessionUUID() {
        return sessionUUID;
    }

    public void setConnection(SseEmitter connection) {
        this.connection = connection;
    }

    public SseEmitter getConnection() {
        return connection;
    }

    public boolean isHost() {
        return isHost;
    }

    public String getName() {
        return name;
    }

    public UUID getPlayerId() {
        return playerId;
    }
    public void setAlive(boolean alive){
        isAlive=alive;
    }

    public boolean isAlive() {
        return isAlive;
    }
}
