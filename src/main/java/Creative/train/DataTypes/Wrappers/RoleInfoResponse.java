package Creative.train.DataTypes.Wrappers;

import Creative.train.GameLogic.Roles.Role;

public class RoleInfoResponse {
    public RoleInfoResponse(String name, String hex, Role.Team team){
        this.hex = hex;
        this.name = name;
        this.team = team;
    }
    public String name;
    public  String hex;
    public Role.Team team;
}
