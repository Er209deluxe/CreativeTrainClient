package Creative.train.Backend.ExceptionTypes;

public class NotEnoughCoinsException extends Exception{
    public NotEnoughCoinsException() {
        super("Not enough coins");
    }

}
