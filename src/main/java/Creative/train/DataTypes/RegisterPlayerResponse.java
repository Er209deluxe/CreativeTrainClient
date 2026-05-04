package Creative.train.DataTypes;

import Creative.train.DataTypes.RequestTypes.PlayerInformation;
import com.fasterxml.jackson.annotation.JsonInclude;
import org.springframework.http.ResponseEntity;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class RegisterPlayerResponse {
    private PlayerInformation playerInformation;
    private ResponseEntity<?> response;
    private boolean isHost;
    public void setPlayerInformation(PlayerInformation playerInformation) {
        this.playerInformation = playerInformation;
    }

    public boolean isHost() {
        return isHost;
    }

    public void setHost(boolean host) {
        isHost = host;
    }

    public void setResponse(ResponseEntity<?> response) {
        this.response = response;
    }

    public PlayerInformation getHostInformation() {
        return playerInformation;
    }

    public ResponseEntity<?> getResponse() {
        return response;
    }
}
