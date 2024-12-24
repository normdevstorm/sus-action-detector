part of '../app.dart';

class ConstantManager {
  static const int defaultRequestTiemoutInSeconds = 60;
  static const int defaultRecordNumber = 10;
  static const String defaultProfileAvatar =
      "https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg";
  static const List<Map<String, String>> defaultDoctorWorkingShifts = [
    {'7:00 AM': 'Morning'},
    {'8:00 AM': 'Morning'},
    {'9:00 AM': 'Morning'},
    {'10:00 AM': 'Morning'},
    {'11:00 AM': 'Morning'},
    {'1:00 PM': 'Afternoon'},
    {'2:00 PM': 'Afternoon'},
    {'3:00 PM': 'Afternoon'},
    {'4:00 PM': 'Afternoon'},
    {'5:00 PM': 'Afternoon'},
  ];

  static const String firebaseRtdbRefConstant = 'iot';
}
