package Creative.train.GameLogic;

import Creative.train.ConfigManagement.RoleDataManager;
import Creative.train.DataTypes.GlobalVariableHolder;
import Creative.train.DataTypes.Session;
import Creative.train.GameLogic.Roles.*;

import Creative.train.Managers.SessionManager;
import ch.qos.logback.core.testUtil.MockInitialContext;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class RoleAssignerTest {
    int playersNeededForNewSpecialRole = RoleAssigner.playersNeededForNewSpecialRole;
    int specialRolesPerCount = 3;
    UUID sessionUuid = UUID.randomUUID();
    @BeforeEach
    void setup() throws IOException {

        // deterministic role pools for testing
        GlobalVariableHolder.killerClasses =
                List.of(Killer.class);

        GlobalVariableHolder.neutralClasses =
                List.of(Neutral.class);

        GlobalVariableHolder.innocentClasses =
                List.of(Innocent.class, Vigilante.class);

        InputStream stream = getClass().getResourceAsStream("/testData/test.json");
        assertNotNull(stream);

        String json = new String(
                stream.readAllBytes(),
                StandardCharsets.UTF_8
        );

        SessionManager.roleLoader(json,sessionUuid);

    }


    @Test
    void createRoles_when_I_SpecialSets_creates_I_OfEachSpecialRole() {
        for (long i = 0; i < 5; i++) {
            List<Role> roles = RoleAssigner.createRoles((int) (playersNeededForNewSpecialRole * i), sessionUuid);


            long vigilantes = roles.stream()
                    .filter(r -> r instanceof Vigilante)
                    .count();

            long innocents = roles.stream()
                    .filter(r -> r.getTeam().equals(Role.Team.CIVILIAN))
                    .count();
            innocents = innocents - vigilantes;

            long killers = roles.stream()
                    .filter(r -> r.getTeam().equals(Role.Team.KILLER))
                    .count();
            long neutrals = roles.stream()
                    .filter(r -> r.getTeam().equals(Role.Team.NEUTRAL))
                    .count();
            assertEquals(i, killers);
            assertEquals(i, vigilantes);
            assertEquals(i, neutrals);
            assertEquals(playersNeededForNewSpecialRole * i - i * specialRolesPerCount, innocents);
            assertEquals(playersNeededForNewSpecialRole * i, roles.size());
        }
    }

    @Test
    void createRoles_whenBelow_I_SpecialSets_returnsOnlyIMinus1FillRoles() {
        for (int i = 1; i < 10; i++) {

            List<Role> roles = RoleAssigner.createRoles(i * playersNeededForNewSpecialRole - 1,sessionUuid);

            long vigilantes = roles.stream()
                    .filter(r -> r instanceof Vigilante)
                    .count();

            long innocents = roles.stream()
                    .filter(r -> r.getTeam().equals(Role.Team.CIVILIAN))
                    .count();

            long killers = roles.stream()
                    .filter(r -> r.getTeam().equals(Role.Team.KILLER))
                    .count();
            long neutrals = roles.stream()
                    .filter(r -> r.getTeam().equals(Role.Team.NEUTRAL))
                    .count();

            assertEquals(i-1, killers);
            assertEquals(i-1, vigilantes);
            assertEquals(i-1, neutrals);

            assertEquals(i*playersNeededForNewSpecialRole - 1, roles.size());
        }
    }

    @Test
    void createRoles_neverCreatesMoreRolesThanPlayers() {

        for (int players = 1; players <= 20; players++) {

            List<Role> roles = RoleAssigner.createRoles(players,sessionUuid);

            assertEquals(players, roles.size());
        }
    }
}