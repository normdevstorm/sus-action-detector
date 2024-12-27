import 'package:firebase_dart/database.dart' as additional_firebase_dart;
import 'package:suspicious_action_detection/app/config/firebase_api.dart';
import '../../../app/app.dart';
import '../../../domain/iot/repository/iot_realtime_repository.dart';

class IotRealtimeDatasourceImplWindows implements IotRealtimeRepository {
  final realtimeDbForWindows = additional_firebase_dart.FirebaseDatabase(
      app: FirebaseApi.firebaseWindowsApp);
  final iotRef = ConstantManager.firebaseRtdbRefConstant;
  @override
  Future<void> setDoorStatus(bool isOpen) async {
    await realtimeDbForWindows
        .reference()
        .child(iotRef)
        .child('door')
        .set(isOpen);
  }

  @override
  Stream<bool> getDoorStatus() {
    return realtimeDbForWindows
        .reference()
        .child(iotRef)
        .child('door')
        .onValue
        .map((event) => event.snapshot.value as bool);
  }

  @override
  Future<void> setBellStatus(bool isRing) async {
    await realtimeDbForWindows
        .reference()
        .child(iotRef)
        .child('bell')
        .set(isRing);
  }

  @override
  Stream<bool> getBellStatus() {
    return realtimeDbForWindows
        .reference()
        .child(iotRef)
        .child('bell')
        .onValue
        .map((event) => event.snapshot.value as bool);
  }

  @override
  Stream<AiAnalysisStatusEnum> getAiAnalysis() {
    return realtimeDbForWindows
        .reference()
        .child(iotRef)
        .child("/securityStatus")
        .onValue
        .map((event) {
      final result = event.snapshot.value as String;
      return result.toAiAnalysisStatusEnum();
    });
  }
}
