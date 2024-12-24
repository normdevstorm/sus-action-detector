import 'package:firebase_database/firebase_database.dart';
import '../../../app/app.dart';
import '../../../domain/iot/repository/iot_realtime_repository.dart';

class IotRealtimeDatasourceImpl implements IotRealtimeRepository {
  final databaseRef = FirebaseDatabase.instance.refFromURL(
      "https://cloud-message-test-1d41b-default-rtdb.asia-southeast1.firebasedatabase.app/");
  final iotRef = ConstantManager.firebaseRtdbRefConstant;
  @override
  Future<void> setDoorStatus(bool isOpen) async {
    await databaseRef.child(iotRef).set({'door': isOpen});
  }

  @override
  Stream<bool> getDoorStatus() {
    return databaseRef
        .child(iotRef)
        .child('door')
        .onValue
        .map((event) => event.snapshot.value as bool);
  }

  @override
  Future<void> setBellStatus(bool isRing) async {
    await databaseRef.child(iotRef).set({'bell': isRing});
  }

  @override
  Stream<bool> getBellStatus() {
    return databaseRef
        .child(iotRef)
        .child('bell')
        .onValue
        .map((event) => event.snapshot as bool);
  }

  @override
  Stream<AiAnalysisStatusEnum> getAiAnalysis() {
    return databaseRef
        .child(iotRef)
        .child("/securityStatus")
        .onValue
        .map((event) {
      final result = event.snapshot as String;
      return result.toAiAnalysisStatusEnum();
    });
  }
}
