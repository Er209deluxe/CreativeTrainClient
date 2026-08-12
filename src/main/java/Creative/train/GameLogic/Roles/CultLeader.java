package Creative.train.GameLogic.Roles;

import Creative.train.DataTypes.Wrappers.DeathInformation;

import java.util.UUID;

public class CultLeader extends Role{
    public CultLeader(UUID sessionUuid) {
        super(sessionUuid,"CultLeader",Team.NEUTRAL,true,"#fff");

    }

    @Override
    public void onDeath(DeathInformation information){
        session.removePreventingNeutral(this);

    }
}
