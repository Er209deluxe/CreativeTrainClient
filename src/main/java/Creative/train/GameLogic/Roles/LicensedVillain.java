package Creative.train.GameLogic.Roles;

import Creative.train.DataTypes.Wrappers.DeathInformation;
import Creative.train.Managers.SessionManager;

import java.util.UUID;

public class LicensedVillain extends Role{
    public LicensedVillain(UUID sessionUuid) {
        super(
                sessionUuid,
                "Licensed Villain",
                Role.Team.NEUTRAL,
                true,
                "#CF6800");

    }

    @Override
    public void onDeath(DeathInformation information){
        session.removePreventingNeutral(this);
    }
}
