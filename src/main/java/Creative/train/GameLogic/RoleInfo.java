package Creative.train.GameLogic;

import Creative.train.GameLogic.Roles.Role;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@Retention(RetentionPolicy.RUNTIME)
public @interface RoleInfo {
    String name();
    Role.Team team();
    String hex();
}