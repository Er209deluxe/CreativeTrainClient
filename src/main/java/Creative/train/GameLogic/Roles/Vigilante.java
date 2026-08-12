package Creative.train.GameLogic.Roles;

import Creative.train.DataTypes.Wrappers.DeathInformation;
import Creative.train.GameLogic.Items.Gun;

import java.util.UUID;

public class Vigilante extends Role{

    public Vigilante(UUID sessionUuid) {
        super( sessionUuid, "Vigilante",Team.CIVILIAN,false,"#0092fa");
    }

    @Override
    public void onDeath(DeathInformation information){
        //todo: drop gun
    }
}
