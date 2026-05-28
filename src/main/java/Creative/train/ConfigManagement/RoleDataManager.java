package Creative.train.ConfigManagement;

import Creative.train.ConfigManagement.Wrappers.RoleData;
import org.springframework.web.servlet.function.RouterFunctionDslKt;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

public class RoleDataManager {
    private static final ConcurrentHashMap<UUID,ConcurrentHashMap<String, RoleData>> roleDataMap = new ConcurrentHashMap<>();
    private static final RoleDataManager Instance = new RoleDataManager();
    private RoleDataManager(){

    }

    public static RoleDataManager getInstance() {
        return Instance;
    }

    public static RoleData getRoleData(UUID sessionUuid, String name){
        return roleDataMap.get(sessionUuid).get(name);
    }
    public void addRoleData(UUID sessionUuid, String className, RoleData roleData) {
        roleDataMap
                .computeIfAbsent(sessionUuid, k -> new ConcurrentHashMap<>())
                .put(className, roleData);
    }
}
