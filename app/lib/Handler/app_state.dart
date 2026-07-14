import 'dart:async';

import 'package:creativetrainclient/Handler/handle_client_api_requests.dart';

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
      //leave session
    }
    inSession = true;
    _currentSession = sessionData;
  }
  static void setRole(RoleWrapper roleData){
    if(inSession) {
      if(_ipAddress==null) return;
      leaveSession(_ipAddress!, _currentSession.playerUuid, _currentSession.token);
    }

    _role = roleData;
  }
  static RegisterResponse getCurrentSession(){
    return _currentSession;
  }
}