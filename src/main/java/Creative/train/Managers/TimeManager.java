package Creative.train.Managers;

import Creative.train.Backend.api.SseHandler;
import Creative.train.DataTypes.Session;
import Creative.train.GameLogic.Roles.Role;
import Creative.train.Managers.ThreadManager;
import Creative.train.Managers.SessionManager;

import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

public class TimeManager {
    private ScheduledFuture<?> timerTask;
    private final Session session;
    private final AtomicInteger remainingSeconds;
    private final AtomicInteger passedSeconds;

    public TimeManager(Session session) {
        this.session = session;
        remainingSeconds = new AtomicInteger(session.getGeneralConfig().getBaseTimer());
        passedSeconds = new AtomicInteger(0);
        System.out.println("remainingsecs: "+remainingSeconds);
    }
    public void startCountdown(){
        timerTask = ThreadManager.getScheduler().scheduleAtFixedRate(() -> {
            try {

                if (remainingSeconds.get() <= 0) {
                    SessionManager.getInstance().endSession(
                            session.getSessionId(),
                            Role.Team.CIVILIAN,
                            "Killers ran out of time"
                    );
                    return;
                }

                int minutes = remainingSeconds.get() / 60;
                int seconds = remainingSeconds.get() % 60;

                String display = String.format("%02d:%02d", minutes, seconds);

                System.out.println(display);

                SseHandler.sendTimerUpdates(
                        session.getAllPlayerUuids(),
                        display
                );

                handlePassiveIncome(passedSeconds);
                renewChallenge(passedSeconds);

                remainingSeconds.decrementAndGet();
                passedSeconds.incrementAndGet();

            } catch (Exception e) {
                e.printStackTrace();
            }
        }, 0, 1, TimeUnit.SECONDS);
    }
    private void renewChallenge(AtomicInteger seconds){
        if(seconds.get()%30!=0) return;
        session.getAllPlayers().forEach(player -> {
            if (player.getRole().isPassiveIncomeEnabled()) {
                player.generateNewChallange();
            }
        });
    }
    public void changeRemainingSecondsBy(int changeBy) {
        remainingSeconds.addAndGet(changeBy);

    }

    private void handlePassiveIncome(AtomicInteger passedSeconds){

        if(passedSeconds.get()%60!=0) return;

        session.getAllPlayers().forEach(player -> {
            if (player.getRole().isPassiveIncomeEnabled()) {
                player.earnPassiveIncome();
            }
        });


    }

    public void stopCountdown() {
        if (timerTask != null && !timerTask.isCancelled()) {
            timerTask.cancel(false);
        }
        System.out.println("Timer stopped");
    }

}
