import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../../../app/app.dart';
import '../../../domain/iot/repository/iot_realtime_repository.dart';

class IotRealtimeDatasourceImpl implements IotRealtimeRepository {
  final firebaseAuth = FirebaseAuth.instance;
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
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  @override
  Stream<User?> userChanges() {
    return firebaseAuth.userChanges();
  }

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

  // @override
  // Stream<WarningLevelEnum> getAiAnalysis() {
  //   return databaseRef
  //       .child(iotRef)
  //       .child("/securityStatus")
  //       .onValue
  //       .map((event) {
  //     final result = event.snapshot.value as String;
  //     return result.toAiAnalysisStatusEnum();
  //   });
  // }

  @override
  Stream<List<String>> getWarningLevelOneImageUrls() async* {
    while (true) {
      try {
        final ListResult listResult = await levelOneWarningRef.listAll();
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
      await Future.delayed(Duration(seconds: 3));
    }
// Adjust interval as needed
  }

  @override
  Stream<List<String>> getWarningLevelTwoImageUrls() async* {
    while (true) {
      try {
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
      await Future.delayed(Duration(seconds: 3));
    }
// Adjust interval as needed
  }

  @override
  Stream<WarningLevelEnum> getAiAnalysis() async* {
    while (true) {
      // Create an infinite loop
      try {
        bool levelOneAlert = await databaseRef
            .child(ConstantManager.firebaseRtdbAlertLevelOneRefConstant)
            .child("detected")
            .get()
            .then((value) => value.value as bool);
        bool levelTwoAlert = await databaseRef
            .child(ConstantManager.firebaseRtdbAlertLevelTwoRefConstant)
            .child("detected")
            .get()
            .then((value) => value.value as bool);

        if (!levelOneAlert && !levelTwoAlert) {
          yield WarningLevelEnum.safe;
        } else if (levelOneAlert && !levelTwoAlert) {
          yield WarningLevelEnum.dubious;
        } else {
          yield WarningLevelEnum.dangerous;
        }
      } on Exception catch (e) {
        Logger().e(e);
        yield WarningLevelEnum.safe;
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}
