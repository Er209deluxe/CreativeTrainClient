class GeneralConfig {
  int baseTimerMins;
  int baseTimerSecs;
  int incrementTimerOnKillInSeconds;
  int killReward;
  int passiveIncome;
  DepressionData depressionData;

  GeneralConfig(
      this.baseTimerMins,
      this.baseTimerSecs,
      this.incrementTimerOnKillInSeconds,
      this.killReward,
      this.passiveIncome,
      this.depressionData,
      );

  Map<String, dynamic> toJson() {
    return {
      "baseTimerMins": baseTimerMins,
      "baseTimerSecs": baseTimerSecs,
      "incrementTimerOnKillInSeconds": incrementTimerOnKillInSeconds,
      "killReward": killReward,
      "passiveIncome": passiveIncome,
      "depressionData": depressionData.toJson(),
    };
  }
}

class DepressionData {
  /// Time it takes for depression to kill you.
  int baseDepression;

  /// Time before depression activates.
  int baseSanity;

  DepressionData(this.baseDepression, this.baseSanity);

  Map<String, dynamic> toJson() {
    return {
      "baseDepression": baseDepression,
      "baseSanity": baseSanity,
    };
  }
}