package Creative.train.GameLogic.Items;

public class Gun extends Weapon{
    public Gun(){
        super("Gun",30,0);
    }

    @Override
    public Item copy() {
        Gun copy = new Gun();
        copy.setPrice(this.price);
        return copy;
    }
}
