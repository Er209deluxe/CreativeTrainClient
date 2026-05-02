package Creative.train.Api.Backend;

import Creative.train.DataTypes.GlobalVariableHolder;
import Creative.train.DataTypes.Player;
import Creative.train.DataTypes.RegisterPlayerResponse;
import Creative.train.DataTypes.RequestTypes.HostInformation;
import Creative.train.Managers.QrManager;
import Creative.train.Managers.SessionManager;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.awt.image.BufferedImage;
import java.util.UUID;

@RestController
@RequestMapping(GlobalVariableHolder.apiPrefix+"/session")
public class SessionApi {
    static final SessionManager sessionManager=SessionManager.getInstance();
    private String playerName;
    private UUID joinedSession;
    private MultipartFile playerQr;


    @PostMapping("/registerUser")
    public ResponseEntity<?> registerUser(
            @RequestParam("playerName") String playerName,
            @RequestParam(value = "joinedSession", required = false) UUID joinedSession,
            @RequestParam("playerQr") MultipartFile playerQr // Accepting file upload via @RequestParam
    ) {
        this.playerName = playerName;
        this.joinedSession = joinedSession;
        this.playerQr = playerQr;
        if (playerQr.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("No file uploaded.");
        }

        // Convert the uploaded MultipartFile to BufferedImage for QR code processing
        BufferedImage qrImage;
        UUID playerUuid;
        try {
            qrImage = QrManager.convertMultipartFileToBufferedImage(playerQr);
            // Read the QR code from the image
            String result =QrManager.readQrCode(qrImage);
            System.out.println(result);
            playerUuid = UUID.fromString(result);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Couldn't process the QR Code.");
        }
        // Create the player object
        Player player = new Player(
                playerName,
                playerUuid,
                (joinedSession == null) // Assuming this is for host checking
        );

        // Register the player into the session
        RegisterPlayerResponse result = sessionManager.registerPlayerToSession(joinedSession, player);

        // Return the response based on registration result
        if (result.getHostInformation() != null) {
            return ResponseEntity.ok(result.getHostInformation());
        }

        return result.getResponse();
    }

    @PostMapping("/start")
    public ResponseEntity<?> startSession(@RequestBody HostInformation data){
        UUID hostUuid = data.getHostUuid();
        UUID sessionUuid = data.getSessionId();
        if(sessionManager.getSession(sessionUuid)==null){
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Session not found");
        }

        if(!sessionManager.getHostUuid(sessionUuid).equals(hostUuid)){
            return ResponseEntity.status(403).body("You are not the host");
        }
        return ResponseEntity.status(HttpStatus.OK).body("OK");
    }
}
