import 'dart:convert';

import 'package:creativetrainclient/Handler/app_state.dart';
import 'package:creativetrainclient/Wrappers/RoleWrapper.dart';

void playerJoined(String? data){
  if(data!=null) {
    print("${data.replaceAll('\n', '')} joined");
    app_state.getCurrentSession().addPlayer(data);
  }
}
void playerLeft(String? data) {
  if (data != null) {
    print("${data.replaceAll('\n', '')} left");
    app_state.getCurrentSession().removePlayer(data);
  }
}
  void updateChallenge(String? challenge){
    if(challenge==null){
      return;
    }
    print("Challenge: ${challenge.replaceAll('\n', '')}");
    app_state.updateChallenge(challenge);
  }
  void sessionStart(String? data){
      if(data==null) return;

      RoleWrapper role = RoleWrapper.fromJson(jsonDecode(data));
      print("session started role: ${role.team.name}");
      app_state.setRole(role);
      app_state.gameStarted = true;
  }
