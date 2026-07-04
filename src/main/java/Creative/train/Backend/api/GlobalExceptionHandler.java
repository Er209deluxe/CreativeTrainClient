package Creative.train.Backend.api;

import Creative.train.Backend.ExceptionTypes.*;
import org.apache.tomcat.websocket.AuthenticationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<?> AuthenticationException(Creative.train.Backend.ExceptionTypes.AuthenticationException ex){
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(ex.getMessage());
    }
    @ExceptionHandler(UserAlreadyInSessionExcepion.class)
    public ResponseEntity<String> userAlreadyInSession(UserAlreadyInSessionExcepion ex) {
        return ResponseEntity.status(409).body(ex.getMessage());
    }

    @ExceptionHandler(UsernameAlreadyExistsException.class)
    public ResponseEntity<String> usernameAlreadyExists(UsernameAlreadyExistsException ex) {
        return ResponseEntity.status(409).body(ex.getMessage());
    }
    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<String> playerNotFoundException(NotFoundException ex){
        return ResponseEntity.status(484).body(ex.getMessage());

    }
    @ExceptionHandler(InventoryFullException.class)
    public ResponseEntity<String> inventoryFullException(InventoryFullException ex){
        return ResponseEntity.status(HttpStatus.CONFLICT).body(ex.getMessage());

    }
    @ExceptionHandler(NotEnoughCoinsException.class)
    public ResponseEntity<String> notEnoughCoinsException(NotEnoughCoinsException ex){
        return ResponseEntity.status(HttpStatus.CONFLICT).body(ex.getMessage());

    }
}
