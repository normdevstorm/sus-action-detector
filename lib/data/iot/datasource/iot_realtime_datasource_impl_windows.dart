import 'package:firebase_dart/database.dart' as additional_firebase_dart;
import 'package:firebase_dart/storage.dart' as additional_firebase_storage_dart;
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:suspicious_action_detection/app/config/firebase_api.dart';
import '../../../app/app.dart';
import '../../../domain/iot/repository/iot_realtime_repository.dart';

class IotRealtimeDatasourceImplWindows implements IotRealtimeRepository {
  final realtimeDbForWindows = additional_firebase_dart.FirebaseDatabase(
      app: FirebaseApi.firebaseWindowsApp);
  static final _firestorageForWindows =
      additional_firebase_storage_dart.FirebaseStorage.instanceFor(
          bucket: "gs://cloud-message-test-1d41b.appspot.com");
  final iotRef = ConstantManager.firebaseRtdbRefConstant;
  final levelOneWarningRef = _firestorageForWindows.ref(
      "${ConstantManager.imageStoragePathConstant}/${ConstantManager.imageStorageLevelOneWarning}");
  final levelTwoWarningRef = _firestorageForWindows.ref(
      "${ConstantManager.imageStoragePathConstant}/${ConstantManager.imageStorageLevelTwoWarning}");
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
  Stream<WarningLevelEnum> getAiAnalysis() {
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

  @override
  Stream<List<String>> getWarningLevelOneImageUrls() async* {
    try {
      final additional_firebase_storage_dart.ListResult listResult =
          await levelOneWarningRef.listAll();
      List<String> urls = [];
      for (final item in listResult.items) {
        final url = (await item.getDownloadURL());
        urls.add(url);
      }
      yield urls;
    } catch (e) {
      Logger().e(e);
      yield [];
    }
    await Future.delayed(Duration(seconds: 10)); // Adjust interval as needed
  }

  @override
  Stream<List<String>> getWarningLevelTwoImageUrls() async* {
    try {
      final additional_firebase_storage_dart.ListResult listResult =
          await levelTwoWarningRef.listAll();
      List<String> urls = [];
      for (final item in listResult.items) {
        final url = (await item.getDownloadURL());
        urls.add(url);
      }
      yield urls;
    } catch (e) {
      Logger().e(e);
      yield [];
    }
    await Future.delayed(Duration(seconds: 10)); // Adjust interval as needed
  }
}
