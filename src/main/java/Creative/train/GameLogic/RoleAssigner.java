package Creative.train.GameLogic;

import Creative.train.DataTypes.GlobalVariableHolder;
import Creative.train.DataTypes.Player;
import Creative.train.DataTypes.Session;
import Creative.train.GameLogic.Roles.Role;
import Creative.train.GameLogic.Roles.Vigilante;
import Creative.train.Managers.SessionManager;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class RoleAssigner {
    private final static SessionManager sessionManager = SessionManager.getInstance();
    public static int playersNeededForNewSpecialRole=3; //for testing, real value should be 6

    public static void assignAllRoles(Session session, List<Class<? extends Role>> removedRoles) throws Exception {
        List<UUID> uuids = session.getAllPlayerUuids();

        List<Role> roles = createRoles(uuids.size(),session.getSessionId(),removedRoles);
        for(UUID uuid : uuids){
            Player player = sessionManager.getPlayer(uuid);
            int max = roles.size();
            int index = (int) Math.floor((Math.random() * max));
            player.assignRole(roles.get(index));
            roles.remove(index);
        }
    }
    private static Role getRandomRole(List<Class<? extends Role>> classList,UUID sessionUuid){
        int max = classList.size();
        int index = (int) (Math.random() * max);

        try {

            return classList.get(index).getDeclaredConstructor(UUID.class).newInstance(sessionUuid);
        } catch (Exception e) {
        System.err.println(
                "Failed to create role: " + classList.get(index).getName()
        );
        e.printStackTrace();

        if (e instanceof java.lang.reflect.InvocationTargetException ite) {
            Throwable cause = ite.getCause();
            System.err.println("Actual constructor exception:");
            if (cause != null) {
                cause.printStackTrace();
            }
        }

        return null;
    }

    }

    static List<Role> createRoles(int playerCount,UUID sessionUuid,List<Class<? extends Role>> removedRoles) throws Exception {
        List<Role> roleList=new ArrayList<>();
        var killers = new ArrayList<>(GlobalVariableHolder.killerClasses);
        var neutrals = new ArrayList<>(GlobalVariableHolder.neutralClasses);
        var innocents = new ArrayList<>(GlobalVariableHolder.innocentClasses);

        killers.retainAll(removedRoles);
        neutrals.retainAll(removedRoles);
        innocents.retainAll(removedRoles);

        if(killers.isEmpty()) throw new Exception("Can't start session without a killer");
        if(innocents.isEmpty()) throw new Exception("Can't start session without civilians");
        int sets = playerCount / playersNeededForNewSpecialRole;
        //add a new killer/neutral for every playersNeededForNewSpecialRole players
        for (int i = 0; i < sets; i++) {

            Role killer = getRandomRole(killers,sessionUuid);
            Role neutral = getRandomRole(neutrals,sessionUuid);

            if (killer != null) roleList.add(killer);
            if (neutral != null) roleList.add(neutral);

            roleList.add(new Vigilante(sessionUuid));
        }


        var noVigiInnocents = innocents.stream().filter(aClass -> !aClass.equals(Vigilante.class)).toList();
        while (roleList.size() < playerCount) {
            Role role = getRandomRole(noVigiInnocents, sessionUuid);

            if (role == null) {
                throw new IllegalStateException(
                        "Could not create an innocent role for session " + sessionUuid
                );
            }

            roleList.add(role);
        }


        return roleList;
    }

}
