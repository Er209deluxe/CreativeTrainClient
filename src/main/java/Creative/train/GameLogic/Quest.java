package Creative.train.GameLogic;

import java.util.UUID;

public class Quest {

    private final String questToken;
    private final String description;

    public Quest(String questToken, String description) {
        this.questToken = questToken;
        this.description = description;
    }

    public String getQuestToken() {
        return questToken;
    }

    public String getDescription() {
        return description;
    }
}