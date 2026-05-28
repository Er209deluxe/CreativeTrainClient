package Creative.train.ConfigManagement;

import Creative.train.ConfigManagement.Wrappers.RoleData;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

public class RoleLoader {

    private final ObjectMapper mapper = new ObjectMapper();

    public void load(String json, UUID sessionUuid) throws JsonProcessingException {

        JsonNode root = mapper.readTree(json);
        JsonNode roleNode = root.get("roleConfig");

        if (roleNode == null || !roleNode.isArray()) {
            throw new IllegalArgumentException("roleConfig missing or not an array");
        }

        for (JsonNode role : roleNode) {

            RoleData roleData = mapper.treeToValue(role, RoleData.class);

            RoleDataManager.getInstance().addRoleData(sessionUuid, roleData.name, roleData);
        }
    }
}