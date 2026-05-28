package Creative.train.DataTypes;

import Creative.train.GameLogic.Roles.Innocent;
import Creative.train.GameLogic.Roles.Killer;
import Creative.train.GameLogic.Roles.Role;
import Creative.train.GameLogic.Roles.Vigilante;

import java.util.ArrayList;
import java.util.List;

public class GlobalVariableHolder {
    public final static String apiPrefix = "/api";
    public static List<Class<? extends Role>> killerClasses =
            List.of(
                    Killer.class
            );

    public static List<Class<? extends Role>> neutralClasses =
            List.of();

    public static List<Class<? extends Role>> innocentClasses =
            List.of(
                    Innocent.class,
                    Vigilante.class
            );

    /**
     *
     * @param team The classes allignment
     * @param className the class youre searching
     * @return the class extending Role returns null if no class with that name is found
     */
    public static Class<?> getRoleClass(Role.Team team,String className){
        switch(team){
            case CIVILIAN -> {
                return searchClass(innocentClasses,className);
            }
            case NEUTRAL -> {
                return searchClass(neutralClasses,className);
            }
            case KILLER -> {
                return searchClass(killerClasses,className);
            }
        }
        return null;
    }
    private static Class<?> searchClass(List<Class<? extends Role>> classList,String className){
        for(Class<? extends Role> classItem : classList ){
            if(classItem.getName().equals(className)){
                return classItem;
            }
        }
        return null;
    }
}
