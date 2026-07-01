package Creative.train.Managers;

import Creative.train.Backend.ExceptionTypes.SessionNotFoundException;
import Creative.train.Backend.ExceptionTypes.UserAlreadyInSessionExcepion;
import Creative.train.DataTypes.Wrappers.PlayerData;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

import Creative.train.DataTypes.Player;
import Creative.train.DataTypes.RegisterPlayerResponse;
import Creative.train.Managers.SessionManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.UUID;
import java.util.concurrent.Executor;

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

        PlayerData response =
                sessionManager.registerPlayerToSession(
                        null,
                        host,
                        tokenHash
                );

        assertNotNull(response);

        assertTrue(response.isHost);

        assertEquals(host.getPlayerId(), response.playerUuid);

        assertNotNull(response.sessionUuid);

        assertNotNull(tokenHash);
        assertNotNull(token);
        assertTrue(host.isCorrectPass(token));

        assertEquals(host, sessionManager.getPlayer(host.getPlayerId()));
    }

    @Test
    void validateSpecialSymbols(){
        String token = EncryptionManager.generateNewToken();
        String tokenHash = EncryptionManager.sha256(token);
        String[] names = { "!", "@", "#", "#", "$", "%", "^", "&", "*", "(", ")", "_", "+", "{", "}"," ",null};
        names[names.length-1] = String.join("",names);
        for(String name : names) {
            Player host = new Player(name,UUID.randomUUID(),tokenHash,true);

            PlayerData response =
                    sessionManager.registerPlayerToSession(
                            null,
                            host,
                            tokenHash
                    );
            assertNotNull(response);

            assertTrue(response.isHost);

            assertEquals(host.getPlayerId(), response.playerUuid);

            assertNotNull(response.sessionUuid);

            assertNotNull(tokenHash);
            assertNotNull(token);
            assertTrue(host.isCorrectPass(token));

            assertEquals(host, sessionManager.getPlayer(host.getPlayerId()));
        }
    }

    @Test
    void shouldFailWhenPlayerAlreadyExists() {

        String tokenHash = EncryptionManager.sha256(EncryptionManager.generateNewToken());
        Player host = new Player("name",UUID.randomUUID(),tokenHash,true);


        sessionManager.registerPlayerToSession(null, host, tokenHash);

        assertThrowsExactly(UserAlreadyInSessionExcepion.class, () -> sessionManager.registerPlayerToSession(null, host, tokenHash)
        );
    }

    @Test
    void shouldFailWhenSessionDoesNotExist() {

        String tokenHash = EncryptionManager.sha256(EncryptionManager.generateNewToken());
        Player player = new Player("name",UUID.randomUUID(),tokenHash,false);

        assertThrowsExactly(SessionNotFoundException.class, () -> sessionManager.registerPlayerToSession(UUID.randomUUID(), player, tokenHash));

    }

    @Test
    void shouldJoinExistingSessionSuccessfully() {

        // create host/session
        String tokenHash = EncryptionManager.sha256(EncryptionManager.generateNewToken());
        Player host = new Player("name",UUID.randomUUID(),tokenHash,true);


        PlayerData hostResponse =
                sessionManager.registerPlayerToSession(
                        null,
                        host,
                        tokenHash
                );

        UUID sessionId = hostResponse.sessionUuid;;

        // joining player
        Player joiningPlayer = new Player("name2",UUID.randomUUID(),tokenHash,false);


        PlayerData joinResponse =
                sessionManager.registerPlayerToSession(
                        sessionId,
                        joiningPlayer,
                        tokenHash
                );

        assertFalse(joinResponse.isHost);

        assertEquals(joiningPlayer.getPlayerId(), joinResponse.playerUuid);

        assertEquals(sessionId, joinResponse.sessionUuid);
    }
}