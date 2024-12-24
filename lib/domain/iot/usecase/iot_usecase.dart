
import '../../../app/app.dart';
import '../repository/iot_realtime_repository.dart';

class IotUsecase {
  final IotRealtimeRepository iotRealtimeDatasource;

  const IotUsecase({required this.iotRealtimeDatasource});

  Future<void> setDoorStatus(bool isOpen) async {
    await iotRealtimeDatasource.setDoorStatus(isOpen);
  }

  Stream<bool> getDoorStatus() {
    return iotRealtimeDatasource.getDoorStatus();
  }

  Future<void> setBellStatus(bool isRing) async {
    return await iotRealtimeDatasource.setBellStatus(isRing);
  }

  Stream<bool> getBellStatus() {
    return iotRealtimeDatasource.getBellStatus();
  }

  Stream<AiAnalysisStatusEnum> getAiAnalysis() {
    return iotRealtimeDatasource.getAiAnalysis();
  }
}
