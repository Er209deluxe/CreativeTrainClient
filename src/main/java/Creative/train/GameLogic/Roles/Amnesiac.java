package Creative.train.GameLogic.Roles;

import Creative.train.DataTypes.Wrappers.DeathInformation;

import java.util.UUID;

public class Amnesiac extends Role{
    public Amnesiac(UUID sessionUuid) {
        super(sessionUuid,"Amnesiac",Team.NEUTRAL,false,"#8F8F8F");
    }

    @Override
    public void onDeath(DeathInformation information){

    }
}
