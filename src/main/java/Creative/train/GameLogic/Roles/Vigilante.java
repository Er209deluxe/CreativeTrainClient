package Creative.train.GameLogic.Roles;

import Creative.train.DataTypes.GlobalVariableHolder;
import Creative.train.GameLogic.Items.Gun;

import java.util.UUID;

public class Vigilante extends Role{

    public Vigilante(UUID sessionUuid) {
        super( sessionUuid, "Vigilante");
        Gun gun = new Gun("Revolver");
        baseInventory.add(gun);
    }

}
