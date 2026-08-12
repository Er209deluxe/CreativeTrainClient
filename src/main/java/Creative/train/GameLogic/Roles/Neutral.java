package Creative.train.GameLogic.Roles;

import Creative.train.DataTypes.Wrappers.DeathInformation;

import java.util.UUID;

public class Neutral extends Role{
    public Neutral(UUID sessionUuid) {
        super( sessionUuid ,"Neutral",Team.NEUTRAL,false, "#fff");
    }

    @Override
    public void onDeath(DeathInformation information){

    }
}
