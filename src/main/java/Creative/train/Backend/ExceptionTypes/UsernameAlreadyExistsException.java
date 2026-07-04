package Creative.train.Backend.ExceptionTypes;

import java.util.UUID;

public class UsernameAlreadyExistsException extends RuntimeException{
    public UsernameAlreadyExistsException(String playerName) {
        super("Username already joined: " + playerName);
    }
}
