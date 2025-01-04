import 'package:flutter/foundation.dart'
    show kIsWeb, TargetPlatform, defaultTargetPlatform;
import 'package:suspicious_action_detection/data/iot/datasource/iot_realtime_datasource_impl.dart';
import 'package:suspicious_action_detection/data/iot/datasource/iot_realtime_datasource_impl_windows.dart';

import '../../../app/app.dart';
import '../repository/iot_realtime_repository.dart';

class IotUsecase {
  final IotRealtimeRepository iotRealtimeDatasource;

  const IotUsecase._({required this.iotRealtimeDatasource});

  factory IotUsecase() {
    if (defaultTargetPlatform == TargetPlatform.windows && !kIsWeb) {
      return IotUsecase._(
          iotRealtimeDatasource: IotRealtimeDatasourceImplWindows());
    }
    return IotUsecase._(iotRealtimeDatasource: IotRealtimeDatasourceImpl());
  }

  Future signIn(String email, String password) async {
    return await iotRealtimeDatasource.signIn(email, password);
  }

  Future<void> signOut() async {
    await iotRealtimeDatasource.signOut();
  }

  Stream userChanges() {
    return iotRealtimeDatasource.userChanges();
  }

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

  Stream<WarningLevelEnum> getAiAnalysis() {
    return iotRealtimeDatasource.getAiAnalysis();
  }

  Stream<List<String>> getWarningLevelOneImageUrls() {
    return iotRealtimeDatasource.getWarningLevelOneImageUrls();
  }

  Stream<List<String>> getWarningLevelTwoImageUrls() {
    return iotRealtimeDatasource.getWarningLevelTwoImageUrls();
  }
}
