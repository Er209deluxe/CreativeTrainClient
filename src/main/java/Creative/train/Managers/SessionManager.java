package Creative.train.Managers;

import Creative.train.Backend.ExceptionTypes.NotFoundException;
import Creative.train.Backend.ExceptionTypes.UserAlreadyInSessionExcepion;
import Creative.train.Backend.api.SseHandler;
import Creative.train.ConfigManagement.RoleLoader;
import Creative.train.DataTypes.Player;
import Creative.train.DataTypes.Wrappers.*;
import Creative.train.DataTypes.Session;
import Creative.train.GameLogic.GeneralConfig;
import Creative.train.GameLogic.Items.Gun;
import Creative.train.GameLogic.Items.Item;
import Creative.train.GameLogic.Items.Weapon;
import Creative.train.GameLogic.RoleAssigner;
import Creative.train.GameLogic.Roles.LicensedVillain;
import Creative.train.GameLogic.Roles.Role;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.util.*;

public class SessionManager {
    private final Map<UUID,Player> playerMap;
    private final Map<UUID, Session> sessions;
    private static final SessionManager sessionManager = new SessionManager();
    private SessionManager(){
        sessions = new HashMap<>();
        playerMap = new HashMap<>();
    }
    public Player getPlayer(UUID playerUuid){
        return playerMap.get(playerUuid);
    }

    public static SessionManager getInstance() {
        return sessionManager;
    }

    public Session getSession(UUID uuid){
        return sessions.get(uuid);
    }
    public Session registerSession(UUID playerUuid){
        Session newSession = new Session(playerUuid);

        sessions.put(newSession.getSessionId(),newSession);
        return newSession;
    }
    public void addPlayer(Session session,Player player) throws NotFoundException {

        if (getPlayer(player.getPlayerId())!=null) {
            throw new UserAlreadyInSessionExcepion(player.getPlayerId());
        }

        if (!player.isHost() && getSession(session.getSessionId())==null) {
            throw new NotFoundException("Session",session.getSessionId());
        }
        session.addPlayer(player);

        playerMap.put(player.getPlayerId(),player);
    }

    public PlayerData registerPlayerToSession(UUID sessionUuid, Player player,String token) throws NotFoundException {

        Session session = getSession(sessionUuid);
        if (session == null&&!player.isHost()) {
            throw new NotFoundException("Session",sessionUuid);
        }
        if (player.isHost()) {
            session = registerSession(player.getPlayerId());
            System.out.println("Hostuuid: "+session.getHostUuid());
        }
        addPlayer(session,player);

        PlayerData playerData = new PlayerData();
        playerData.sessionUuid = session.getSessionId();
        playerData.playerUuid = player.getPlayerId();
        playerData.token = token;
        playerData.isHost = player.isHost();
        return playerData;
    }


    public Player getHostUuid(UUID sessionUuid) throws NotFoundException {
        Session session = getSession(sessionUuid);
        if (session == null) throw new NotFoundException("Session",sessionUuid);

        UUID hostUuid = session.getHostUuid();
        if (hostUuid == null) return null;

        return getPlayer(hostUuid);
    }
    /**
     *
     * @param sessionUuid sessionUuid
     * @return every username in session
     * @throws NullPointerException when no session is found
     */
    public Set<String> getAllNamesInSession(UUID sessionUuid){
        Session session = getSession(sessionUuid);
        if(session == null) return null;
        return session.getAllNames();
    }
    public List<UUID> getAllUuidsInSession(UUID sessionUuid){
        Session session = getSession(sessionUuid);
        if(session == null) return null;
        return session.getAllPlayerUuids();
    }
    public void removePlayer(UUID playerUuid){
        Player player =getPlayer(playerUuid);
        if(player==null) return;
        UUID sessionUuid=player.getSessionUUID();
        Session session = getSession(sessionUuid);
        if(session.isActive()){
            DeathInformation information = new DeathInformation(null,player,null);
            setPlayerDead(information);
        }
        playerMap.remove(playerUuid);
        if(session==null) return;
        session.removePlayer(playerUuid);
        System.out.println("removed:"+playerUuid);
    }
    public boolean startSession(UUID sessionUuid,JsonNode roleJson,JsonNode configJson) throws Exception {
        Session session = getSession(sessionUuid);
        List<Class<? extends Role>> removedRoles;
            removedRoles = roleLoader(roleJson.get("roleConfig"), sessionUuid);

        if(removedRoles == null) return false;

        RoleAssigner.assignAllRoles(session,removedRoles);

        ObjectMapper mapper = new ObjectMapper();
        GeneralConfig generalConfig =mapper.treeToValue(configJson, GeneralConfig.class);

        session.start(generalConfig);

        SseHandler.sendSessionStart(getAllUuidsInSession(sessionUuid));
        return true;
    }
    public void endSession(UUID sessionUuid, Role.Team winners,String reason){
        SessionEndData sessionEndData = new SessionEndData();
        Session session = getSession(sessionUuid);
        //if(session==null) return;

        session.stop();
        sessionEndData.winnerTeam = winners;
        sessionEndData.reason = reason;

        List<BasePlayerData> playerEndScreenInfoList = new ArrayList<>();
        List<UUID> playerUuids=session.getAllPlayerUuids();
        for(UUID playerUuid : playerUuids){
            Player player = SessionManager.getInstance().getPlayer(playerUuid);
            playerEndScreenInfoList.add(player.getBaseData());
        }

        sessionEndData.playerDataList = playerEndScreenInfoList;
        SseHandler.sendSessionEnd(playerUuids,sessionEndData);

        removeSession(session);

    }
    private void removeSession(Session session){
        session.getAllPlayerUuids().forEach(this::removePlayer);
        sessions.remove(session.getSessionId());
    }
    public static List<Class<? extends Role>> roleLoader(JsonNode json, UUID sessionUuid) throws Exception {
        RoleLoader loader = new RoleLoader();
        try {
            return loader.load(json, sessionUuid);
        } catch (IOException e){
            //failed to parse json
            return null;
        }
    }
    public boolean isSessionActive(UUID sessionUuid) throws NotFoundException {
        Session session = getSession(sessionUuid);
        if(session==null) throw new NotFoundException("Session",sessionUuid);
        return getSession(sessionUuid).isActive();
    }

    public List<String> transferDroppedItems(Player sender, Player receiver) {
        Iterator<DroppedItem> iterator = sender.getItemDrops().iterator();
        List<String> failedItems = new ArrayList<>();
        while (iterator.hasNext()) {
            DroppedItem droppedItem = iterator.next();
            Item item = droppedItem.getItem();

            if (item instanceof Gun && !receiver.getRole().canPickupGun()) {
                failedItems.add(item.getName());
                continue;
            }

            if (!receiver.hasItem(item.getClass()) && receiver.addItem(item)) {
                getSession(sender.getSessionUUID()).getTimeManager().removeDecrementItem(droppedItem);
                iterator.remove();
                continue;
            }
            failedItems.add(item.getName());


        }
        if(!failedItems.isEmpty()){
            SseHandler.sendFailedTransfer(sender.getPlayerId(),failedItems);
        }
        return failedItems;
    }

    public void setPlayerDead(DeathInformation information){
        Player victim = information.getVictim();
        if(!victim.isAlive()) return;

        victim.triggerDeath();
        victim.getRole().onDeath(information);

        SseHandler.sendDeathInfo(victim.getPlayerId());

        Session session = getSession(victim.getSessionUUID());
        session.decrementAlivePlayers(victim);

        if(!information.getVictim().getRole().getTeam().equals(Role.Team.KILLER)) return;
        session.getTimeManager().changeRemainingSecondsBy
                (session.getGeneralConfig().getIncrementTimerOnKillInSeconds());
    }
    public String startKillAction(Player killer, Player victim, UUID itemUuid, UUID sessionUuid) throws Exception {
        if(!isSessionActive(killer.getSessionUUID())) throw new Exception("Session is not active");
        if(!killer.isAlive()) throw new Exception("You are not alive");
        if(!victim.isAlive()) throw new Exception("Victim is already dead");

        Item item = killer.getItem(itemUuid);
        if(item==null) throw new Exception("Item does not exist");

        if(!(item instanceof Weapon weapon)){
            throw new Exception("Item is not a Weapon");
        }
        DeathInformation information = new DeathInformation(killer,victim,weapon);
        long expireTime = System.currentTimeMillis()+30*1000;
        information.setExpireTime(expireTime);
        if(!weapon.isOnCooldown()){
            throw new Exception("Weapon is still on cooldown");
        }
        return getSession(sessionUuid).addKillAction(information);
    }
    public void killPlayer(UUID sessionUuid, String killToken) throws Exception {
        Session session = getSession(sessionUuid);
        DeathInformation deathInformation = session.getKillAction(killToken);
        Player killer = deathInformation.getKiller();

        if(deathInformation.getExpireTime()<System.currentTimeMillis()){
            session.removeKillAction(killToken);
            throw new Exception("kill has expired");
        }
        deathInformation.getItem().killAbility(deathInformation);
        boolean isLicensedVillain = deathInformation.getKiller().getRole() instanceof LicensedVillain;
        if(
                deathInformation.getItem() instanceof Gun &&
                deathInformation.getVictim().getRole().getTeam().equals(Role.Team.CIVILIAN) &&
                !isLicensedVillain
        )
        {
            DroppedItem droppedGun = new DroppedItem(killer, deathInformation.getItem(),session.getGeneralConfig().getGunTransferTimeInSeconds());
            killer.dropItem(droppedGun);

            return;
        }
        if(killer.getRole().getRoleInfo().team().equals(Role.Team.KILLER)) {
            killer.changeCoins(session.getGeneralConfig().getKillReward());
        }
    }
}
