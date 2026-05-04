package Creative.train.Api.WebServer;

import org.springframework.web.bind.annotation.GetMapping;

public class LoadPages {
    @GetMapping("/")
    public String home() {
        return "index.html";
    }
}
