package Creative.train.ConfigManagement.Wrappers;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;

public class DepressionData {
    //public final boolean depresionKilling;

    // Time it takes for depression to kill you
    public final int baseDepression;

    // Time before depression activates
    public final int baseSanity;
    @JsonCreator
    public DepressionData(
            @JsonProperty("baseDepression") int baseDepression,
            @JsonProperty("baseSanity") int baseSanity
    ) {
        this.baseDepression = baseDepression;
        this.baseSanity = baseSanity;
    }
}
