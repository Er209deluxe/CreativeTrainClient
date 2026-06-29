package Creative.train.GameLogic;

import Creative.train.ConfigManagement.Wrappers.DepressionData;

import java.util.concurrent.TimeUnit;

public class GeneralConfig {

    private final int baseTimerMins;
    private final int baseTimerSecs;

    private final DepressionData depressionData;
    private final int passiveIncome;
    public GeneralConfig(
            DepressionData depressionData,
            int passiveIncome,
            int baseTimerMins,
            int baseTimerSecs
    ) {
        this.depressionData = depressionData;
        this.passiveIncome = passiveIncome;

        this.baseTimerMins = baseTimerMins;
        this.baseTimerSecs = baseTimerSecs;
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

    /**
     * Returns the depression kill timer in the requested unit.
     * Supported:
     * - "s"  = seconds
     * - "ms" = milliseconds
     * - "m"  = minutes
     *
     * @param unit the unit to return
     * @return converted time value
     */
    public long getDepressedTimer(String unit) {

        return switch (unit.toLowerCase()) {

            case "s" ->
                    depressionData.depressedKillingTimerInSeconds;

            case "ms" ->
                    TimeUnit.SECONDS.toMillis(
                            depressionData.depressedKillingTimerInSeconds
                    );

            case "m" ->
                    TimeUnit.SECONDS.toMinutes(
                            depressionData.depressedKillingTimerInSeconds
                    );

            default ->
                    throw new IllegalArgumentException(
                            "Unsupported unit: " + unit
                    );
        };
    }

    /**
     * Returns the depression activation timer
     * in the requested unit.
     * Supported:
     * - "s"  = seconds
     * - "ms" = milliseconds
     * - "m"  = minutes
     *
     * @param unit the unit to return
     * @return converted time value
     */
    public long getDepressionActivationTimer(String unit) {

        return switch (unit.toLowerCase()) {

            case "s" ->
                    depressionData.depressionActivationInSeconds;

            case "ms" ->
                    TimeUnit.SECONDS.toMillis(
                            depressionData.depressionActivationInSeconds
                    );

            case "m" ->
                    TimeUnit.SECONDS.toMinutes(
                            depressionData.depressionActivationInSeconds
                    );

            default ->
                    throw new IllegalArgumentException(
                            "Unsupported unit: " + unit
                    );
        };
    }
}