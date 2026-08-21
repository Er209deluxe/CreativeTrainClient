package Creative.train.GameLogic.Roles;

import Creative.train.DataTypes.Wrappers.DeathInformation;
import Creative.train.GameLogic.RoleInfo;

import java.util.UUID;

@RoleInfo(name = "Neutral",team = Role.Team.NEUTRAL,hex = "#fff")
public class Neutral extends Role{
    public Neutral(UUID sessionUuid) {
        super(sessionUuid,false);
    }

    @Override
    public void onDeath(DeathInformation information){

    }
}
