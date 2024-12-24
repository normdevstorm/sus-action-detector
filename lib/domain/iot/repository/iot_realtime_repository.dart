import '../../../app/app.dart';

abstract class IotRealtimeRepository {
  Future<void> setDoorStatus(bool isOpen);
  Stream<bool> getDoorStatus();
  Future<void> setBellStatus(bool isRing);
  Stream<bool> getBellStatus();
  Stream<AiAnalysisStatusEnum> getAiAnalysis();
}
