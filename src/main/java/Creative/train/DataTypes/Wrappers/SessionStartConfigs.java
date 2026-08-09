package Creative.train.DataTypes.Wrappers;

import com.fasterxml.jackson.databind.JsonNode;

public class SessionStartConfigs {

    private JsonNode roleConfig;
    private JsonNode generalConfig;

    public JsonNode getRoleConfig() {
        return roleConfig;
    }

    public void setRoleConfig(JsonNode roleConfig) {
        this.roleConfig = roleConfig;
    }

    public JsonNode getGeneralConfig() {
        return generalConfig;
    }

    public void setGeneralConfig(JsonNode generalConfig) {
        this.generalConfig = generalConfig;
    }
}