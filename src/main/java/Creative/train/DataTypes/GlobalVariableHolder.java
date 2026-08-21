package Creative.train.DataTypes;

import Creative.train.GameLogic.Roles.*;

import java.util.ArrayList;
import java.util.List;

public class GlobalVariableHolder {
    public final static String apiPrefix = "/api";
    public static List<Class<? extends Role>> killerClasses =
            new ArrayList<>(List.of(
                    Killer.class
            ));

    public static List<Class<? extends Role>> neutralClasses =
            new ArrayList<>(List.of(
                    LicensedVillain.class,
                    Amnesiac.class,
                    Jester.class,
                    CultLeader.class
            ));

    public static List<Class<? extends Role>> innocentClasses =
            new ArrayList<>(List.of(
                    Innocent.class,
                    Vigilante.class
            ));

    /**
     *
     * @param className the class youre searching
     * @return the class extending Role returns null if no class with that name is found
     */
    public static Class<? extends Role> getRoleClass(String className) {
        Class<? extends Role> roleClass;

        roleClass = searchClass(innocentClasses, className);
        if (roleClass != null) {
            return roleClass;
        }

        roleClass = searchClass(neutralClasses, className);
        if (roleClass != null) {
            return roleClass;
        }

        roleClass = searchClass(killerClasses, className);
        return roleClass;
    }

    private static Class<? extends Role> searchClass(List<Class<? extends Role>> classList,String className){
        for(Class<? extends Role> classItem : classList ){
            if(classItem.getSimpleName().equals(className)){
                return classItem;
            }
        }
        return null;
    }
}
