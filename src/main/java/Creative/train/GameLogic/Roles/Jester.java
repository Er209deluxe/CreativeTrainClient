package Creative.train.GameLogic.Roles;

import Creative.train.DataTypes.Wrappers.KillInformation;
import Creative.train.GameLogic.RoleInfo;
import Creative.train.Managers.SessionManager;

import java.util.UUID;
@RoleInfo(
        name="Jester",
        team = Role.Team.NEUTRAL,
        hex = "#CF00C1"
)
public class Jester extends Role{
    public Jester(UUID sessionUuid) {
        super(sessionUuid,false);

    }

    @Override
    public void onDeath(KillInformation information){
        if(information.getKiller()==null) return;

        if(information.getKiller().getRole().getRoleInfo().team().equals(Team.CIVILIAN)){
            SessionManager.getInstance().endSession(session.getSessionId(),Team.NEUTRAL,"Jester has been killed");
        }
    }
}
