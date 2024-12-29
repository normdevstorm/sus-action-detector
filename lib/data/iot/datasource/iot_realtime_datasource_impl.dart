import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import '../../../app/app.dart';
import '../../../domain/iot/repository/iot_realtime_repository.dart';

class IotRealtimeDatasourceImpl implements IotRealtimeRepository {
  final iotRef = ConstantManager.firebaseRtdbRefConstant;
  static final _imageStoragePath = ConstantManager.imageStoragePathConstant;
  final databaseRef = FirebaseDatabase.instance.refFromURL(
      "https://cloud-message-test-1d41b-default-rtdb.asia-southeast1.firebasedatabase.app/");
  final levelOneWarningRef = FirebaseStorage.instance
      .ref()
      .child(_imageStoragePath)
      .child(ConstantManager.imageStorageLevelOneWarning);
  final levelWoWarningRef = FirebaseStorage.instance
      .ref()
      .child(_imageStoragePath)
      .child(ConstantManager.imageStorageLevelTwoWarning);
  @override
  Future<void> setDoorStatus(bool isOpen) async {
    await databaseRef.child(iotRef).child('door').set(isOpen);
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
    await databaseRef.child(iotRef).child('bell').set(isRing);
  }

  @override
  Stream<bool> getBellStatus() {
    return databaseRef
        .child(iotRef)
        .child('bell')
        .onValue
        .map((event) => event.snapshot.value as bool);
  }

  @override
  Stream<WarningLevelEnum> getAiAnalysis() {
    return databaseRef
        .child(iotRef)
        .child("/securityStatus")
        .onValue
        .map((event) {
      final result = event.snapshot.value as String;
      return result.toAiAnalysisStatusEnum();
    });
  }

  @override
  Stream<List<String>> getWarningLevelOneImageUrls() {
    return levelOneWarningRef.listAll().asStream().map((event) {
      return event.items.map((e) => e.fullPath).toList();
    });
  }

  @override
  Stream<List<String>> getWarningLevelTwoImageUrls() async* {
    try {
      // final additional_firebase_storage_dart.ListResult listResult =
      //     await levelTwoWarningRef.listAll();
      final ListResult listResult = await levelWoWarningRef.listAll();
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
