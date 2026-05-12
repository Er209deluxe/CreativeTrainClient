package Creative.train.GameLogic.Roles;

public abstract class Role {

    protected final String name;
    protected final Team team;

    public Role(String name, Team team) {
        this.name = name;
        this.team = team;

    }

    public String getName() {
        return name;
    }

    public Team getTeam() {
        return team;
    }

    public enum Team {
        CIVILIAN,
        NEUTRAL,
        KILLER
    }
}
