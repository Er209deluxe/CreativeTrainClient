package Creative.train.GameLogic.Items;

import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;

import java.util.List;
import java.util.UUID;

@JsonTypeInfo(
        use = JsonTypeInfo.Id.NAME,
        include = JsonTypeInfo.As.PROPERTY,
        property = "type"
)
@JsonSubTypes({
        @JsonSubTypes.Type(value = Knife.class, name = "Knife"),
        @JsonSubTypes.Type(value = Gun.class, name = "Gun"),
        @JsonSubTypes.Type(value = Food.class, name = "Food")
})
public abstract class Item {
    protected List<String> tags;
    protected UUID itemUuid;
    protected int price;
    protected String name;
    protected Item(String name,List<String> tags){
        this.name=name;
        itemUuid = UUID.randomUUID();
        this.tags = tags;
    }
    public void setPrice(int price) {
        this.price = price;
    }

    public UUID getItemUuid() {
        return itemUuid;
    }

    public void setItemUuid(UUID itemUuid) {
        this.itemUuid = itemUuid;
    }

    public int getPrice() {
        return price;
    }

    public String getName() {
        return name;
    }
}
