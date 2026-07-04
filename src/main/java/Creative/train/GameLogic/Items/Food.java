package Creative.train.GameLogic.Items;

import java.util.ArrayList;
import java.util.List;

public class Food extends Item {
    static {
        List<String> tags = new ArrayList<>();
        tags.add("food");
    }
 public Food(){
     super("food",
             new ArrayList<>(
                     List.of("food")

             ));
 }
}
