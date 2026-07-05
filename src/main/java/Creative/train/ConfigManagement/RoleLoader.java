package Creative.train.ConfigManagement;

import Creative.train.ConfigManagement.Wrappers.RoleData;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.UUID;

public class RoleLoader {

    private final ObjectMapper mapper = new ObjectMapper();

    public void load(JsonNode root, UUID sessionUuid) throws JsonProcessingException {

        JsonNode roleNode = root.get("roleConfig");
        System.out.println(root.toPrettyString());

        if (roleNode == null || !roleNode.isArray()) {
            throw new IllegalArgumentException("roleConfig missing or not an array");
        }

        for (JsonNode role : roleNode) {

            RoleData roleData = mapper.treeToValue(role, RoleData.class);

            RoleDataManager.addRoleData(sessionUuid, roleData.name, roleData);
        }
    }
}