void playerJoined(String? data){
  if(data!=null) {
    print("${data.replaceAll('\n', '')} joined");
  }
}
void playerLeft(String? data){
  if(data!=null) {
    print("${data.replaceAll('\n', '')} left");
  }
}