package Creative.train.GameLogic.Roles;

import Creative.train.DataTypes.GlobalVariableHolder;
import Creative.train.DataTypes.Wrappers.DeathInformation;

import java.util.UUID;

public class Innocent extends Role{

    public Innocent(UUID sessionUuid) {
        super(sessionUuid,"Innocent",Team.CIVILIAN,false,"#02d926");
    }

    @Override
    public void onDeath(DeathInformation information){

    }
}
