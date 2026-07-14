class RegisterResponse {
  final String playerUuid;
  final bool isHost;
  final String sessionUuid;
  final String token;
  final List<String> playerList;
  final String hostName;
  late int coinCount;

  void setCoins(int coins){
    coinCount = coins;
  }
  void addPlayer(String playerName){
    playerList.add(playerName);
  }
  void removePlayer(String playerName){
    playerList.remove(playerName);
  }
  RegisterResponse({
    required this.playerUuid,
    required this.isHost,
    required this.sessionUuid,
    required this.token,
    required this.playerList,
    required this.hostName
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json,List<String> playerList,String hostName) {
    return RegisterResponse(
      playerUuid: json['playerUuid'] as String,
      isHost: json['isHost'] as bool,
      sessionUuid: json['sessionUuid'] as String,
      token: json['token'] as String,
      playerList: playerList,
      hostName: hostName
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "playerUuid": playerUuid,
      "isHost": isHost,
      "sessionUuid": sessionUuid,
      "token": token,
      "playerList": playerList,
      "hostName": hostName,
    };
  }
}