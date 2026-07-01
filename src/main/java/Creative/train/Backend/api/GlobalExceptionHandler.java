package Creative.train.Backend.api;

import Creative.train.Backend.ExceptionTypes.SessionNotFoundException;
import Creative.train.Backend.ExceptionTypes.UserAlreadyInSessionExcepion;
import Creative.train.Backend.ExceptionTypes.UsernameAlreadyExistsException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(SessionNotFoundException.class)
    public ResponseEntity<String> sessionNotFound(SessionNotFoundException ex) {
        return ResponseEntity.status(404).body(ex.getMessage());
    }

    @ExceptionHandler(UserAlreadyInSessionExcepion.class)
    public ResponseEntity<String> userAlreadyInSession(UserAlreadyInSessionExcepion ex) {
        return ResponseEntity.status(409).body(ex.getMessage());
    }

    @ExceptionHandler(UsernameAlreadyExistsException.class)
    public ResponseEntity<String> usernameAlreadyExists(UsernameAlreadyExistsException ex) {
        return ResponseEntity.status(409).body(ex.getMessage());
    }
}
