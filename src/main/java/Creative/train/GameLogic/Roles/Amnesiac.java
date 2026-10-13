package Creative.train.GameLogic.Roles;

import Creative.train.DataTypes.Wrappers.DeathInformation;
import Creative.train.GameLogic.RoleInfo;

import java.util.UUID;
@RoleInfo(
        name="Amnesiac",
        team= Role.Team.NEUTRAL,
        hex="#8F8F8F"
)
public class Amnesiac extends Role{
    public Amnesiac(UUID sessionUuid) {
        super(sessionUuid,false);
    }


    @Override
    public void onDeath(DeathInformation information){

    }
}
