package Creative.train.DataTypes.Wrappers;

import Creative.train.GameLogic.Roles.Role;

import java.util.List;

public class SessionEndData {
    public Role.Team winnerTeam;
    public List<BasePlayerData> playerDataList;
    public String reason;
}
