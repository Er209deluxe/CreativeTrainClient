package Creative.train.GameLogic.Roles;

import Creative.train.ConfigManagement.RoleDataManager;
import Creative.train.ConfigManagement.Wrappers.RoleData;
import Creative.train.GameLogic.Items.Item;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public abstract class Role {

    protected final String name;
    protected final Team team;
    protected final String hex;

    protected boolean enableShop;
    protected boolean passiveIncome;
    protected int taskIncome;
    final List<Item> itemShop = new ArrayList<>();
    final List<Item> baseInventory = new ArrayList<>();

    public Role(UUID sessionUuid,String name,Team team,String hex) {
        RoleData data = RoleDataManager.getRoleData(sessionUuid,name);
        this.name = name;
        this.team = team;
        this.hex = hex;
        this.enableShop = data.enableShop;
        this.passiveIncome = data.passiveIncome;
        this.taskIncome = data.taskIncome;

    }

    public boolean isShopEnabled() {
        return enableShop;
    }

    public int getTaskIncome() {
        return taskIncome;
    }

    public boolean isPassiveIncomeEnabled() {
        return passiveIncome;
    }

    public List<Item> getItemShop() {
        return itemShop;
    }

    public List<Item> getBaseInventory() {
        return baseInventory;
    }

    public String getHex(){
        return hex;
    }
    public String getName() {
        return name;
    }

    public Team getTeam() {
        return team;
    }

    public enum Team {
        CIVILIAN,
        NEUTRAL,
        KILLER
    }
}
