package Creative.train.GameLogic.Items;

import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;

import java.util.List;
import java.util.UUID;

@JsonTypeInfo(
        use = JsonTypeInfo.Id.NAME,
        include = JsonTypeInfo.As.EXISTING_PROPERTY,
        property = "name",
        visible = true
)
@JsonSubTypes({
        @JsonSubTypes.Type(value = Gun.class, name = "Gun"),
        @JsonSubTypes.Type(value = Knife.class, name = "Knife"),
        @JsonSubTypes.Type(value = Food.class, name = "Food")
})
public abstract class Item {
    protected List<String> tags;
    protected UUID itemUuid;
    protected int price;
    protected String name;
    protected boolean dropOnDeath;
    protected boolean killerPickup=true;

    protected Item(String name,List<String> tags){
        this.name=name;
        itemUuid = UUID.randomUUID();
        this.tags = tags;
    }
    public Item copy() {
        try {
            Item clone = this.getClass()
                    .getDeclaredConstructor()
                    .newInstance();

            clone.name = this.name;
            clone.price = this.price;
            clone.tags = this.tags != null ? List.copyOf(this.tags) : null;
            clone.itemUuid = UUID.randomUUID();
            clone.dropOnDeath = this.dropOnDeath;
            clone.killerPickup = this.killerPickup;

            return clone;

        } catch (Exception e) {
            throw new RuntimeException("Copy failed", e);
        }
    }

    public void setKillerPickup(boolean killerPickup) {
        this.killerPickup = killerPickup;
    }

    public boolean canKillerPickup() {
        return killerPickup;
    }

    public void setPrice(int price) {
        this.price = price;
    }

    public List<String> getTags() {
        return tags;
    }

    public UUID getItemUuid() {
        return itemUuid;
    }

    public void setDropOnDeath(boolean dropOnDeath) {
        System.out.println("dropondeath: "+dropOnDeath);
        this.dropOnDeath = dropOnDeath;
    }

    public boolean isDropOnDeath() {
        return dropOnDeath;
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
