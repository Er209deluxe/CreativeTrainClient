package Creative.train.GameLogic.Items;

import Creative.train.DataTypes.Player;

public abstract class Item {
    protected int price;
    protected final String name;
    public Item(String name){
        this.name=name;
    }
    public void setPrice(int price) {
        this.price = price;
    }

    public int getPrice() {
        return price;
    }
    public void buyItem(Player player){

    }
}
