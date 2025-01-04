import '../../../app/app.dart';


abstract class IotRealtimeRepository {
  Future signIn(String email, String password);
  Future<void> signOut();
  Stream userChanges();
  Future<void> setDoorStatus(bool isOpen);
  Stream<bool> getDoorStatus();
  Future<void> setBellStatus(bool isRing);
  Stream<bool> getBellStatus();
  Stream<WarningLevelEnum> getAiAnalysis();
  Stream<List<String>> getWarningLevelOneImageUrls();
  Stream<List<String>> getWarningLevelTwoImageUrls();
}
