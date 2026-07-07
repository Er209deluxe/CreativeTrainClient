package Creative.train.GameLogic.Roles;


import java.util.UUID;

public class Killer extends Role{

    public Killer(UUID sessionUuid) {
        super( sessionUuid,"Killer",Team.KILLER,"#d90408");
    }

}
