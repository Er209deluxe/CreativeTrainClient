package Creative.train.GameLogic.Roles;

import Creative.train.DataTypes.Wrappers.DeathInformation;
import Creative.train.GameLogic.RoleInfo;

import java.util.UUID;
@RoleInfo(name = "Vigilante",team = Role.Team.CIVILIAN,hex = "#0092fa")
public class Vigilante extends Role{

    public Vigilante(UUID sessionUuid) {
        super( sessionUuid,false);
    }

    @Override
    public void onDeath(DeathInformation information){
        //todo: drop gun
    }
}
