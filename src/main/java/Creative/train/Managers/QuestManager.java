package Creative.train.Managers;

import Creative.train.DataTypes.Player;
import Creative.train.DataTypes.Session;
import Creative.train.GameLogic.Quest;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

public class QuestManager {
    private final Session session;
    private final List<Quest> questPool;

    public QuestManager(Session session){
        this.session = session;
        questPool = List.of(
                new Quest("drink", "Drink something"),
                new Quest("eat", "Eat something"),
                new Quest("homework","Do homework"),
                new Quest("class","Go to class")
        );
    }
    public Quest getRandomQuest(){
        Quest template = questPool.get(ThreadLocalRandom.current().nextInt(questPool.size()));

        return new Quest(template.getQuestToken(), template.getDescription());
    }
    public void assignQuests(){
        SessionManager sessionManager = SessionManager.getInstance();
        sessionManager.getAllUuidsInSession(session.getSessionId()).forEach(uuid -> {
            Player player = sessionManager.getPlayer(uuid);
            player.assignQuest(getRandomQuest());
        });
    }
}
