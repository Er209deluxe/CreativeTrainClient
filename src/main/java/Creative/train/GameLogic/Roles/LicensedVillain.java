package Creative.train.GameLogic.Roles;

import Creative.train.DataTypes.Wrappers.KillInformation;
import Creative.train.GameLogic.RoleInfo;

import java.util.UUID;
@RoleInfo(
        name = "Licensed Villain",
        team = Role.Team.NEUTRAL,
        hex = "#CF6800"
)
public class LicensedVillain extends Role{
    public LicensedVillain(UUID sessionUuid) {
        super(
                sessionUuid,
                true);

    }


    @Override
    public void onDeath(KillInformation information){
        session.removePreventingNeutral(this);
    }
}
