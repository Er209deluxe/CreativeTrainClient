package Creative.train.Backend.WebServer;

import Creative.train.Managers.SessionManager;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.UUID;

@Controller
public class LoadPages {

    @GetMapping("/")
    public String home() {
        return "/Web/index.html";
    }

    @GetMapping("/activeGame")
    public String activeGame(
            @RequestParam(value = "sessionUuid", required = false)
            UUID sessionUuid
    ) {

        // No session UUID provided
        if (sessionUuid == null) {
            return "/Web/index.html";
        }

        // Session does not exist
        if (SessionManager.getInstance().getSession(sessionUuid) == null) {
            return "/Web/index.html";
        }

        // Valid session
        return "/Web/activeGame.html";
    }
}