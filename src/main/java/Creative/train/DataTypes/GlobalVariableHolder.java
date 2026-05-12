package Creative.train.DataTypes;

import Creative.train.GameLogic.Roles.Innocent;
import Creative.train.GameLogic.Roles.Killer;
import Creative.train.GameLogic.Roles.Role;
import Creative.train.GameLogic.Roles.Vigilante;

import java.util.ArrayList;
import java.util.List;

public class GlobalVariableHolder {
    public final static String apiPrefix = "/api";
    public final static List<Class<? extends Role>> killerClasses =
            List.of(
                    Killer.class
            );

    public final static List<Class<? extends Role>> neutralClasses =
            List.of();

    public final static List<Class<? extends Role>> innocentClasses =
            List.of(
                    Innocent.class,
                    Vigilante.class
            );
}
