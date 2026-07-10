import 'dart:async';

import '../Wrappers/register_response.dart';

class app_state {
  static late StreamSubscription sseSubscription;
  static late RegisterResponse _currentSession;
  static String? _ipAddress;
  static bool inGame=false;

  static void changeGameActivation(bool isActive){
    inGame = isActive;
  }

  static bool setIpAddress(String pIpAddress){
    if(inGame) return false;
    _ipAddress = pIpAddress;
    return true;
  }
  static String? getIpAddress() {
    return _ipAddress;
  }
  static void setCurrentSession(RegisterResponse sessionData){
    if(inGame) {
      //leave session
    }
    inGame = true;
    _currentSession = sessionData;
  }
  static RegisterResponse getCurrentSession(){
    return _currentSession;
  }
}