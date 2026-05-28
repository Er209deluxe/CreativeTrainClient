package Creative.train.ConfigManagement;

import java.util.concurrent.TimeUnit;

public class GeneralConfig {

    private final boolean depressionKilling;

    // Time it takes for depression to kill you
    private final int depressedKillingTimerInSeconds;

    // Time before depression activates
    private final int depressionActivationInSeconds;

    public GeneralConfig(
            boolean depressionKilling,
            int depressedKillingTimerInSeconds,
            int depressionActivationInSeconds
    ) {
        this.depressionKilling = depressionKilling;
        this.depressedKillingTimerInSeconds =
                depressedKillingTimerInSeconds;

        this.depressionActivationInSeconds =
                depressionActivationInSeconds;
    }

    public boolean isDepressionKillingEnabled() {
        return depressionKilling;
    }

    /**
     * Returns the depression kill timer in the requested unit.
     *
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
                    depressedKillingTimerInSeconds;

            case "ms" ->
                    TimeUnit.SECONDS.toMillis(
                            depressedKillingTimerInSeconds
                    );

            case "m" ->
                    TimeUnit.SECONDS.toMinutes(
                            depressedKillingTimerInSeconds
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
     *
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
                    depressionActivationInSeconds;

            case "ms" ->
                    TimeUnit.SECONDS.toMillis(
                            depressionActivationInSeconds
                    );

            case "m" ->
                    TimeUnit.SECONDS.toMinutes(
                            depressionActivationInSeconds
                    );

            default ->
                    throw new IllegalArgumentException(
                            "Unsupported unit: " + unit
                    );
        };
    }
}