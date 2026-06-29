package Creative.train.ConfigManagement.Wrappers;

public class DepressionData {
    //public final boolean depresionKilling;

    // Time it takes for depression to kill you
    public final int depressedKillingTimerInSeconds;

    // Time before depression activates
    public final int depressionActivationInSeconds;
    public DepressionData(int depressedKillingTimerInSeconds,int depressionActivationInSeconds){
        this.depressedKillingTimerInSeconds = depressedKillingTimerInSeconds;
        this.depressionActivationInSeconds = depressionActivationInSeconds;
    }
}
