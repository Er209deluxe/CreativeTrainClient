import 'dart:async';

import 'package:creativetrainclient/Handler/handle_client_api_requests.dart';
import 'package:flutter/cupertino.dart';

import '../Wrappers/RoleWrapper.dart';
import '../Wrappers/register_response.dart';

class app_state {
  static late StreamSubscription sseSubscription;
  static late RegisterResponse _currentSession;
  static String? _ipAddress;
  static bool inSession=false;
  static bool gameStarted=false;
  static late String _challenge;
  static late final RoleWrapper _role;

  static final ValueNotifier<int> playerListNotifier = ValueNotifier(0);


  static void playerJoined(String name) {
    _currentSession.addPlayer(name);
    playerListNotifier.value++;
  }

  static void playerLeft(String name) {
    _currentSession.removePlayer(name);
    playerListNotifier.value++;
  }
  static bool isGameStarted(){return gameStarted;}
  static void updateChallenge(String challenge){
    _challenge = challenge;
  }
  static void changeGameActivation(bool isActive){
    inSession = isActive;
  }
  static RoleWrapper getRole(){
    return _role;
  }
  static bool setIpAddress(String pIpAddress){
    if(inSession) return false;
    _ipAddress = pIpAddress;
    return true;
  }
  static String? getIpAddress() {
    return _ipAddress;
  }
  static void setCurrentSession(RegisterResponse sessionData){
    if(inSession) {
      return;
    }
    inSession = true;
    _currentSession = sessionData;
  }
  static void setRole(RoleWrapper roleData){
    _role = roleData;
  }
  static RegisterResponse getCurrentSession(){
    return _currentSession;
  }


}