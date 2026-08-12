package Creative.train.GameLogic.Roles;

import Creative.train.ConfigManagement.RoleDataManager;
import Creative.train.ConfigManagement.Wrappers.RoleData;
import Creative.train.DataTypes.GlobalVariableHolder;
import Creative.train.DataTypes.Session;
import Creative.train.DataTypes.Wrappers.DeathInformation;
import Creative.train.GameLogic.Items.Item;
import Creative.train.Managers.SessionManager;

import java.util.*;

public abstract class Role {

    protected final Session session;
    protected final String name;
    protected final Team team;
    protected final String hex;

    protected boolean passiveIncome;
    protected int taskIncome;

    private final Map<UUID,Item>  itemShop = new HashMap<>();
    List<Item> baseInventory;

    public Role(UUID sessionUuid,String name,Team team,boolean endPreventingNeutral,String hex) {
        RoleData data = RoleDataManager.getRoleData(sessionUuid,name);
        session = SessionManager.getInstance().getSession(sessionUuid);
        this.name = name;
        this.team = team;
        this.hex = hex;
        this.passiveIncome = data.passiveIncome;
        this.taskIncome = data.taskIncome;
        this.baseInventory = data.baseInventory;

        switch (team){
            case NEUTRAL -> session.incrementAliveNeutrals();
            case CIVILIAN -> session.incrementAliveCivilians();
            case KILLER -> session.incrementAliveKillers();
        }
        if(endPreventingNeutral){
            session.addPreventingNeutral(this);
        }

        data.itemShop.forEach(item -> {
            this.itemShop.put(item.getItemUuid(),  item);
        });
    }


    public abstract void onDeath(DeathInformation information);

    public int getTaskIncome() {
        return taskIncome;
    }

    public boolean isPassiveIncomeEnabled() {
        return passiveIncome;
    }

    public Map<UUID, Item> getItemShop() {
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
