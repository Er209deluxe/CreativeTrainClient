package Creative.train.Backend.ExceptionTypes;


public class InventoryFullException extends Exception{
    public InventoryFullException() {
        super("Inventory is full");
    }

}
