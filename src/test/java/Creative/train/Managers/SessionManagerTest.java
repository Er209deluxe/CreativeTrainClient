package Creative.train.Managers;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import Creative.train.DataTypes.Player;
import Creative.train.DataTypes.RegisterPlayerResponse;
import Creative.train.Managers.SessionManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class SessionManagerTest {

    private SessionManager sessionManager;
    @BeforeEach
    void setUp() {

        // Because SessionManager is a singleton,
        // use the same instance each test
        sessionManager = SessionManager.getInstance();


    }

    @Test
    void shouldRegisterHostSuccessfully() {
        String token = EncryptionManager.generateNewToken();
        String tokenHash = EncryptionManager.sha256(token);
        Player host = new Player("name",UUID.randomUUID(),tokenHash,true);

        RegisterPlayerResponse response =
                sessionManager.registerPlayerToSession(
                        null,
                        host,
                        tokenHash
                );

        assertNotNull(response.getHostInformation());

        assertTrue(response.isHost());

        assertEquals(
                host.getPlayerId(),
                response.getHostInformation().getPlayerUuid()
        );

        assertNotNull(
                response.getHostInformation().getSessionId()
        );

        assertNotNull(tokenHash);
        assertNotNull(token);
        assertTrue(host.isCorrectPass(token));

        assertEquals(
                host,
                sessionManager.getPlayer(host.getPlayerId())
        );
    }

    @Test
    void validateSpecialSymbols(){
        String token = EncryptionManager.generateNewToken();
        String tokenHash = EncryptionManager.sha256(token);
        String[] names = { "!", "@", "#", "#", "$", "%", "^", "&", "*", "(", ")", "_", "+", "{", "}"," ",null};
        names[names.length-1] = String.join("",names);
        for(String name : names) {
            Player host = new Player(name,UUID.randomUUID(),tokenHash,true);

            RegisterPlayerResponse response =
                    sessionManager.registerPlayerToSession(
                            null,
                            host,
                            tokenHash
                    );
            assertNotNull(response.getHostInformation());

            assertTrue(response.isHost());

            assertEquals(
                    host.getPlayerId(),
                    response.getHostInformation().getPlayerUuid()
            );

            assertNotNull(
                    response.getHostInformation().getSessionId()
            );

            assertNotNull(tokenHash);
            assertNotNull(token);
            assertTrue(host.isCorrectPass(token));

            assertEquals(
                    host,
                    sessionManager.getPlayer(host.getPlayerId())
            );
        }
    }
    @Test
    void shouldFailWhenPlayerAlreadyExists() {

        String tokenHash = EncryptionManager.sha256(EncryptionManager.generateNewToken());
        Player host = new Player("name",UUID.randomUUID(),tokenHash,true);


        sessionManager.registerPlayerToSession(
                null,
                host,
                tokenHash
        );

        RegisterPlayerResponse secondResponse =
                sessionManager.registerPlayerToSession(
                        null,
                        host,
                        tokenHash
                );

        assertEquals(
                409,
                secondResponse.getResponse().getStatusCode().value()
        );
    }

    @Test
    void shouldFailWhenSessionDoesNotExist() {

        String tokenHash = EncryptionManager.sha256(EncryptionManager.generateNewToken());
        Player player = new Player("name",UUID.randomUUID(),tokenHash,false);


        RegisterPlayerResponse response =
                sessionManager.registerPlayerToSession(
                        UUID.randomUUID(),
                        player,
                        tokenHash
                );

        assertEquals(
                404,
                response.getResponse().getStatusCode().value()
        );
    }

    @Test
    void shouldJoinExistingSessionSuccessfully() {

        // create host/session
        String tokenHash = EncryptionManager.sha256(EncryptionManager.generateNewToken());
        Player host = new Player("name",UUID.randomUUID(),tokenHash,true);


        RegisterPlayerResponse hostResponse =
                sessionManager.registerPlayerToSession(
                        null,
                        host,
                        tokenHash
                );

        UUID sessionId =
                hostResponse.getHostInformation().getSessionId();;

        // joining player
        Player joiningPlayer = new Player("name2",UUID.randomUUID(),tokenHash,false);


        RegisterPlayerResponse joinResponse =
                sessionManager.registerPlayerToSession(
                        sessionId,
                        joiningPlayer,
                        tokenHash
                );

        assertFalse(joinResponse.isHost());

        assertEquals(
                joiningPlayer.getPlayerId(),
                joinResponse.getHostInformation().getPlayerUuid()
        );

        assertEquals(
                sessionId,
                joinResponse.getHostInformation().getSessionId()
        );
    }
}