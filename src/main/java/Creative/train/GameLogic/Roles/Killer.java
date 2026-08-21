package Creative.train.GameLogic.Roles;


import Creative.train.DataTypes.Wrappers.DeathInformation;
import Creative.train.GameLogic.RoleInfo;

import java.util.UUID;

@RoleInfo(
        name="Killer",
        team = Role.Team.KILLER,
        hex = "#d90408"
)
public class Killer extends Role{

    public Killer(UUID sessionUuid) {
        super( sessionUuid,false);
    }

    @Override
    public void onDeath(DeathInformation information){

    }
}
