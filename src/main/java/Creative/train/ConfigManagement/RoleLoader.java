package Creative.train.ConfigManagement;

import Creative.train.ConfigManagement.Wrappers.RoleData;
import Creative.train.DataTypes.GlobalVariableHolder;
import Creative.train.GameLogic.Roles.Role;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.UUID;

public class RoleLoader {

    private final ObjectMapper mapper = new ObjectMapper();
    public void load(JsonNode roleNode, UUID sessionUuid) throws JsonProcessingException {

        System.out.println(roleNode.toPrettyString());

        if (roleNode == null || !roleNode.isArray()) {
            throw new IllegalArgumentException("roleConfig missing or not an array");
        }

        for (JsonNode role : roleNode) {

            RoleData roleData = mapper.treeToValue(role, RoleData.class);

            if (!roleData.enabled) {
                Class<? extends Role> roleClass =
                        GlobalVariableHolder.getRoleClass(roleData.name);
                GlobalVariableHolder.removeClass(roleClass);
            }

            RoleDataManager.addRoleData(sessionUuid, roleData.name, roleData);
        }
    }
}