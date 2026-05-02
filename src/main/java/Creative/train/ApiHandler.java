package Creative.train;

import Creative.train.DataTypes.GlobalVariableHolder;
import Creative.train.DataTypes.Player;
import Creative.train.DataTypes.RequestTypes.RegisterUser;
import Creative.train.DataTypes.Session;
import Creative.train.Managers.QrManager;
import Creative.train.Managers.SessionManager;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.util.UUID;

@RestController
@RequestMapping("/api")
public class ApiHandler {
    static final SessionManager sessionManager=SessionManager.getInstance();
    @PostMapping("/registerSession")
    public UUID registerSession(){
        Session newSession = new Session();
        SessionManager.getInstance().registerSession(newSession);
        return newSession.getSessionId();
    }
    @PostMapping("/registerUser")
    public String registerUser(@RequestBody RegisterUser data) {
        if (data != null) {
            String playerName = data.getPlayerName();
            UUID playerUuid = data.getPlayerUuid();
            UUID joinedSession = data.getJoinedSession();

            Player player = new Player(playerName,playerUuid);
            return sessionManager.registerPlayerToSession(joinedSession,player);
        }
        return ResponseFormatter.buildResponse(404,"Data not found","");
    }
    @GetMapping(path="/newPlayerQr",produces = MediaType.IMAGE_JPEG_VALUE)
    public byte[] getQrCode() throws Exception {
        BufferedImage image = QrManager.generateQrCode(GlobalVariableHolder.playerQrCodePrefix +UUID.randomUUID().toString());

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(image, "PNG", baos);

        return baos.toByteArray();
    }


}