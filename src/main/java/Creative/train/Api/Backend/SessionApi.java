package Creative.train.Api.Backend;

import Creative.train.DataTypes.GlobalVariableHolder;
import Creative.train.DataTypes.Player;
import Creative.train.DataTypes.RegisterPlayerResponse;
import Creative.train.DataTypes.RequestTypes.PlayerInformation;
import Creative.train.Managers.QrManager;
import Creative.train.Managers.SessionManager;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.awt.image.BufferedImage;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping(GlobalVariableHolder.apiPrefix+"/session")
public class SessionApi {
    static final SessionManager sessionManager=SessionManager.getInstance();

    @PostMapping("/register")
    public ResponseEntity<?> register(
            @RequestParam("playerName") String playerName,
            @RequestParam("playerQr") MultipartFile playerQr,
            @RequestParam(value = "joinedSession", required = false) UUID joinedSession
    ) {

        ResponseEntity<String> bad_request = validate(playerName, playerQr);
        if (bad_request != null) return bad_request;

        UUID playerUuid;
        try {
            playerUuid = getUuidFronQrCode(playerQr);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Couldn't process QR Code");
        }

        boolean isHost = (joinedSession == null);

        Player player = new Player(playerName, playerUuid, isHost);

        RegisterPlayerResponse result = sessionManager.registerPlayerToSession(joinedSession, player);
        SseHandler websocketHandler= SseHandler.getInstance();

        if (result.isHost()) {
            return ResponseEntity.ok(result.getHostInformation());
        }
        if(result.getHostInformation()!=null) {
            player.setSessionUUID(result.getHostInformation().getSessionId());
            List<UUID> playersInSession = sessionManager.getAllUuidsInSession(joinedSession);
            websocketHandler.sendNewPlayerInfo(playersInSession, playerName);
            return ResponseEntity.ok(result.getHostInformation());
        }

        return result.getResponse();
    }
    private static ResponseEntity<String> validate(String playerName, MultipartFile playerQr) {
        if (playerQr.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("QrCode missing");
        }
        if (playerName.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Username missing");
        }
        return null;
    }

    public static UUID getUuidFronQrCode(MultipartFile playerQr) throws Exception {
        BufferedImage qrImage;
        qrImage = QrManager.convertMultipartFileToBufferedImage(playerQr);

        String result =QrManager.readQrCode(qrImage);
        return UUID.fromString(result);
    }
    @PostMapping("/leaveGame")
    public ResponseEntity<?> leaveGame(@RequestParam UUID playerUuid){
        SseHandler.disconnectPlayer(playerUuid);
        return ResponseEntity.status(HttpStatus.OK).build();
    }
    @PostMapping("/start")
    public ResponseEntity<?> startSession(@RequestBody PlayerInformation data){
        UUID hostUuid = data.getPlayerUuid();
        UUID sessionUuid = data.getSessionId();
        if(sessionManager.getSession(sessionUuid)==null){
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Session not found");
        }

        if(!sessionManager.getHostUuid(sessionUuid).getPlayerId().equals(hostUuid)){
            return ResponseEntity.status(403).body("You are not the host");
        }
        return ResponseEntity.status(HttpStatus.OK).body("OK");
    }
    @GetMapping("/connectedUsers")
    public ResponseEntity<?> getConnectedUsers(@RequestParam("sessionUuid") UUID sessionUuid){
        Set<String> names = sessionManager.getAllNamesInSession(sessionUuid);
        if(names==null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Session not found");
        return ResponseEntity.status(HttpStatus.OK).body(names);
    }
    @GetMapping("/hostName")
    public ResponseEntity<?> getHostName(@RequestParam("sessionUuid") UUID sessionUuid){
        String name = sessionManager.getHostUuid(sessionUuid).getName();
        if(name==null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Host not found");
        return ResponseEntity.status(HttpStatus.OK).body(name);
    }
}
