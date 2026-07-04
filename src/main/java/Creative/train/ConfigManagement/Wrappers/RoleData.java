package Creative.train.ConfigManagement.Wrappers;


import Creative.train.GameLogic.Items.Item;
import Creative.train.GameLogic.Roles.Role.Team;

import java.util.List;

public class RoleData {

    public String name;
    public Team team;
    public String hex;
    public boolean enableShop;
    public boolean passiveIncome;
    public int taskIncome;
    public List<Item> itemShop;
    public List<String> baseItems;
}
