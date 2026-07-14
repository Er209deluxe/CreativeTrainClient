package Creative.train.ConfigManagement.Wrappers;

public class DepressionData {
    //public final boolean depresionKilling;

    // Time it takes for depression to kill you
    public final int baseDepression;

    // Time before depression activates
    public final int baseSanity;
    public DepressionData(int baseDepression,int baseSanity){
        this.baseDepression = baseDepression;
        this.baseSanity = baseSanity;
    }
}
