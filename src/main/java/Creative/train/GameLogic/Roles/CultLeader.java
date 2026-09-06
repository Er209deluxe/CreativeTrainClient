package Creative.train.GameLogic.Roles;

import Creative.train.DataTypes.Wrappers.KillInformation;
import Creative.train.GameLogic.RoleInfo;

import java.util.UUID;

@RoleInfo(
        name="CultLeader",
        team= Role.Team.NEUTRAL,
        hex="#fffff"
)
public class CultLeader extends Role{
    public CultLeader(UUID sessionUuid) {
        super(sessionUuid,true);

    }

    @Override
    public void onDeath(KillInformation information){
        session.removePreventingNeutral(this);

    }
}
