package Creative.train.GameLogic;

import Creative.train.ConfigManagement.Wrappers.DepressionData;

public class GeneralConfig {

    private final int baseTimerMins;
    private final int baseTimerSecs;

    private final int incrementTimerOnKillInSeconds;
    private final int killReward;
    private final DepressionData depressionData;
    private final int passiveIncome;
    public GeneralConfig(
            DepressionData depressionData,
            int passiveIncome,
            int baseTimerMins,
            int baseTimerSecs,
            int killReward,
            int incrementTimerOnDeathInSeconds
    ) {
        this.depressionData = depressionData;
        this.passiveIncome = passiveIncome;

        this.baseTimerMins = baseTimerMins;
        this.baseTimerSecs = baseTimerSecs;

        this.killReward = killReward;
        this.incrementTimerOnKillInSeconds = incrementTimerOnDeathInSeconds;
    }

    public int getIncrementTimerOnKillInSeconds() {
        return incrementTimerOnKillInSeconds;
    }

    public int getKillReward() {
        return killReward;
    }

    public int getBaseTimer() {
        return baseTimerMins * 60 + baseTimerSecs;
    }
    public int getPassiveIncome() {
        return passiveIncome;
    }

    public boolean isDepressionKillingEnabled() {
        return depressionData!=null;
    }

    public int getBaseDepression() {

         return depressionData.baseDepression;

    }

    public int getBaseSanity() {
         return depressionData.baseSanity;
    }
}