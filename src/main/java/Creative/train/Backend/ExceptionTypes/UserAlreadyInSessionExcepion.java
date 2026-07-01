package Creative.train.Backend.ExceptionTypes;

import java.util.UUID;

public class UserAlreadyInSessionExcepion extends RuntimeException{
    public UserAlreadyInSessionExcepion(UUID playerUuid) {
        super("User is already in a session: " + playerUuid);
    }
}
