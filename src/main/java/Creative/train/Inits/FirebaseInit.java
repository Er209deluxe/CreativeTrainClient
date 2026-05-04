package Creative.train.Inits;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Component;

import java.io.FileInputStream;
import java.nio.file.Path;
import java.nio.file.Paths;

@Component
public class FirebaseInit {

    @PostConstruct
    public void init() throws Exception {
        Path path = Paths.get("Keys", "TrainIrlFirebaseKey.json");

        FileInputStream serviceAccount =
                new FileInputStream(path.toFile());

        FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                .build();

        FirebaseApp.initializeApp(options);

        System.out.println("Firebase initialized");
    }
}