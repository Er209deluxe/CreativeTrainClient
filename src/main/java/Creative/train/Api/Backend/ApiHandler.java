package Creative.train.Api.Backend;

import Creative.train.DataTypes.GlobalVariableHolder;
import Creative.train.Managers.QrManager;
import Creative.train.Managers.SessionManager;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.util.UUID;

@RestController
@RequestMapping(GlobalVariableHolder.apiPrefix)
public class ApiHandler {
    static final SessionManager sessionManager=SessionManager.getInstance();

    @GetMapping("/stream")
    public SseEmitter stream(@RequestParam("playerUuid") UUID playerUuid) {

        return SseHandler.getInstance().stream(playerUuid);
    }
    @GetMapping(path="/newPlayerQr",produces = MediaType.IMAGE_JPEG_VALUE)
    public ResponseEntity<byte[]> getQrCode() throws Exception {
        BufferedImage image = QrManager.generateQrCode(UUID.randomUUID().toString());

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(image, "PNG", baos);

        return ResponseEntity.ok()
                .header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
                .body(baos.toByteArray());
    }
    }


