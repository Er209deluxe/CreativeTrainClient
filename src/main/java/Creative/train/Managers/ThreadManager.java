package Creative.train.Managers;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;

public class ThreadManager {

    private static final ScheduledExecutorService SCHEDULER = Executors.newScheduledThreadPool(4);
    private static final ExecutorService SsePool = Executors.newFixedThreadPool(20);
    public static ScheduledExecutorService getScheduler() {
        return SCHEDULER;
    }

    public static ExecutorService getSsePool() {
        return SsePool;
    }
}
