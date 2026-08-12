package Creative.train.GameLogic.Roles;

import Creative.train.Backend.api.SseHandler;
import Creative.train.DataTypes.Wrappers.DeathInformation;
import Creative.train.Managers.SessionManager;

import java.util.UUID;

public class Jester extends Role{
    public Jester(UUID sessionUuid) {
        super(sessionUuid,"Jester", Role.Team.NEUTRAL,false,"#CF00C1");

    }

    @Override
    public void onDeath(DeathInformation information){
        if(information.getKiller()==null) return;

        if(information.getKiller().getRole().team.equals(Team.CIVILIAN)){
            SessionManager.getInstance().endSession(session.getSessionId(),Team.NEUTRAL,"Jester has been killed");
        }
    }
}
