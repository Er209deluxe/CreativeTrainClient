package Creative.train.Backend.ExceptionTypes;


public class NotFoundException extends Exception{
    public NotFoundException(String type,Object object) {
        super(type + " not found: " + object);
    }
}
