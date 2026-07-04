package Creative.train.Backend.ExceptionTypes;


public class AuthenticationException extends Exception{
    public AuthenticationException() {
        super("Invalid token");
    }

}
