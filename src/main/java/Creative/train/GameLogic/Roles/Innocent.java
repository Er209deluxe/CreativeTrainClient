package Creative.train.GameLogic.Roles;

import Creative.train.DataTypes.Wrappers.DeathInformation;
import Creative.train.GameLogic.RoleInfo;

import java.util.UUID;
@RoleInfo(
        name="Innocent",
        team = Role.Team.CIVILIAN,
        hex="#02d926"
)
public class Innocent extends Role{

    public Innocent(UUID sessionUuid) {
        super(sessionUuid,false);
    }

    @Override
    public void onDeath(DeathInformation information){

    }
}
