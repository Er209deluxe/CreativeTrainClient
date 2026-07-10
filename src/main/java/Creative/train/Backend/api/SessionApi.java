package Creative.train.Backend.api;

import Creative.train.Backend.ExceptionTypes.AuthenticationException;
import Creative.train.Backend.ExceptionTypes.InventoryFullException;
import Creative.train.Backend.ExceptionTypes.NotEnoughCoinsException;
import Creative.train.Backend.ExceptionTypes.NotFoundException;
import Creative.train.DataTypes.GlobalVariableHolder;
import Creative.train.DataTypes.Player;
import Creative.train.DataTypes.Wrappers.PlayerData;
import Creative.train.DataTypes.Session;
import Creative.train.Managers.EncryptionManager;
import Creative.train.Managers.QrManager;
import Creative.train.Managers.SessionManager;
import com.fasterxml.jackson.databind.JsonNode;
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
    ) throws NotFoundException {
        if(playerName.length()>20) return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Username too long (max 20 characters)");
        ResponseEntity<String> bad_request = validateQr(playerName, playerQr);
        if (bad_request != null) return bad_request;
        if(joinedSession!=null&&sessionManager.isSessionActive(joinedSession))
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Session already started");

        UUID playerUuid;
        try {
            playerUuid = getUuidFromQrCode(playerQr);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Couldn't process QR Code");
        }
        boolean isHost = (joinedSession == null);
        String sessionToken =EncryptionManager.generateNewToken();
        String hashedToken = EncryptionManager.sha256(sessionToken);

        Player player = new Player(playerName, playerUuid,hashedToken, isHost);

        PlayerData result = sessionManager.registerPlayerToSession(joinedSession, player,sessionToken);

        if (result.isHost) {
            player.setSessionUUID(result.sessionUuid);
            return ResponseEntity.ok(result);
        }
        Session session = sessionManager.getSession(joinedSession);
        if(session.getAllPlayers().size()>=12) return ResponseEntity.status(HttpStatus.CONFLICT).body("Session already full");
        player.setSessionUUID(result.sessionUuid);
        List<UUID> playersInSession = sessionManager.getAllUuidsInSession(joinedSession);
        SseHandler.sendNewPlayerInfo(playersInSession, playerName);
        return ResponseEntity.ok(result);
    }


    private static ResponseEntity<String> validateQr(String playerName, MultipartFile playerQr) {
        if (playerQr.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("QrCode missing");
        }
        if (playerName.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Username missing");
        }
        return null;
    }
    private boolean validatePlayer(UUID playerUuid,String sessionToken) throws NotFoundException, AuthenticationException {
        Player player = sessionManager.getPlayer(playerUuid);
        if(player==null) throw new NotFoundException("player",playerUuid);
        if(!player.isCorrectPass(sessionToken))  throw new AuthenticationException();
        return true;
    }
    public static UUID getUuidFromQrCode(MultipartFile playerQr) throws Exception {
        BufferedImage qrImage;
        qrImage = QrManager.convertMultipartFileToBufferedImage(playerQr);

        String result =QrManager.readQrCode(qrImage);
        return UUID.fromString(result);
    }
    @PostMapping("/leaveGame")
    public ResponseEntity<?> leaveGame(@RequestParam UUID playerUuid,
                                       @RequestParam("sessionToken") String sessionToken){
        Player player = SessionManager.getInstance().getPlayer(playerUuid);
        if(player==null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Player not found");
        if(!player.isCorrectPass(sessionToken)) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Wrong token");
        SseHandler.disconnectPlayer(playerUuid);
        return ResponseEntity.status(HttpStatus.OK).build();
    }
    @PostMapping("/start")
    public ResponseEntity<?> startSession(@RequestParam("token") String token,
                                          @RequestParam("sessionUuid") UUID sessionUuid,
                                          @RequestParam("playerUuid") UUID playerUuid,
                                          @RequestBody JsonNode roleConfig){

        Player host = SessionManager.getInstance().getPlayer(playerUuid);
        if(host==null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Player UUID not found");
        if(!host.isCorrectPass(token))  return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Wrong token");

        Session session = sessionManager.getSession(sessionUuid);
        if(session==null){
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Session not found");
        }
        if(session.isActive()) return ResponseEntity.status(HttpStatus.CONFLICT).body("Session already started");

        try{
            if(!sessionManager.getHostUuid(sessionUuid).getPlayerId().equals(playerUuid)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body("You are not the host");
            }
        } catch (NotFoundException e) {
            return ResponseEntity.status(404).body("Player not found");
        }


        if(!sessionManager.startSession(sessionUuid, roleConfig))
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Could not read JSON");
        return ResponseEntity.status(HttpStatus.OK).build();
    }
    @GetMapping("/inventory")
    public ResponseEntity<?> getInventory(@RequestParam UUID playerUuid,
                                          @RequestParam String sessionToken,
                                          @RequestParam boolean isShop) throws NotFoundException {
        Player player = sessionManager.getPlayer(playerUuid);
        if(player==null) throw new NotFoundException("Player",playerUuid);
        try {
            validatePlayer(player.getPlayerId(), sessionToken);
        } catch (AuthenticationException e){
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(e.getMessage());
        } catch (NotFoundException e){
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }

        if(isShop)
            return ResponseEntity.status(HttpStatus.OK).body(
                    player.getRole().getItemShop().values()
            );

        return ResponseEntity.status(HttpStatus.OK).body(player.getInventory());

    }

    @PostMapping("/buyItem")
    public ResponseEntity<?> buyItem(@RequestParam UUID playerUuid,
                                     @RequestParam String sessionToken,
                                     @RequestParam UUID itemUuid) throws AuthenticationException, NotFoundException, NotEnoughCoinsException, InventoryFullException {
        validatePlayer(playerUuid,sessionToken);
        Player player = sessionManager.getPlayer(playerUuid);
        if(!player.isAlive()) return ResponseEntity.status(HttpStatus.FORBIDDEN).body("You are already dead");
        if(player.buyItem(itemUuid)) return ResponseEntity.ok().build();
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body("That item is not in your item shop");
    }
    @GetMapping("/connectedUsers")
    public ResponseEntity<?> getConnectedUsers(@RequestParam("sessionUuid") UUID sessionUuid){
        Set<String> names = sessionManager.getAllNamesInSession(sessionUuid);
        if(names==null) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Session not found");
        return ResponseEntity.status(HttpStatus.OK).body(names);
    }
    @GetMapping("/hostName")
    public ResponseEntity<?> getHostName(@RequestParam("sessionUuid") UUID sessionUuid) throws NotFoundException {

        Session session = sessionManager.getSession(sessionUuid);
        if (session == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Session not found");
        }

        Player host = sessionManager.getHostUuid(sessionUuid);
        if (host == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Host not found");
        }

        return ResponseEntity.ok(host.getName());
    }
    @PostMapping("/kill")
    public ResponseEntity<?> killPlayer(@RequestParam UUID killerUuid,
                                        @RequestParam("sessionToken") String killerToken,
                                        @RequestParam MultipartFile victimQr,
                                        @RequestParam UUID itemUuid){
        Player killer =sessionManager.getPlayer(killerUuid);
        UUID victimUuid;
        try {
             victimUuid = getUuidFromQrCode(victimQr);
        } catch (Exception e){
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
        Player victim = sessionManager.getPlayer(victimUuid);

        return sessionManager.killPlayer(killer,victim,itemUuid);

    }
    /*@PostMapping("/testusers")
    public ResponseEntity<?> testUsers(@RequestParam int amount) throws NotFoundException {

        SessionManager sm = SessionManager.getInstance();

        Player host = new Player("Host", UUID.randomUUID(),"",true);
        PlayerData data = sm.registerPlayerToSession(null, host, "token");

        UUID sessionId = data.sessionUuid;

        for (int i = 0; i < amount; i++) {
            Player p = new Player("Player" + i, UUID.randomUUID(),"",false);
            sm.registerPlayerToSession(sessionId, p, "");
        }
        return ResponseEntity.status(200).build();
    }*/
}
