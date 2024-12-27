import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suspicious_action_detection/app/app.dart';
import 'package:suspicious_action_detection/app/managers/toast_manager.dart';
import 'package:suspicious_action_detection/domain/iot/usecase/iot_usecase.dart';

// ignore: must_be_immutable
class FeatureBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double? height;
  final double? width;
  final IotUsecase iotUsecase = IotUsecase();
  final IotRTDBVariableType type;
  String data = '';

  FeatureBox({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.type,
    this.height,
    this.width,
    this.color = Colors.blue,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: getIotVariableStream(type),
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Center(child: CircularProgressIndicator());
          // }
          if (snapshot.hasError) {
            ToastManager.showToast(
                context: context,
                message: snapshot.error?.toString() ?? '',
                isErrorToast: true);
          }
          if (snapshot.hasData) {
            getIotVariableValue(snapshot);
          }
          return Container(
            height: height,
            width: width,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: getColor((snapshot.data is AiAnalysisStatusEnum
                  ? snapshot.data
                  : null)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: color),
                const SizedBox(height: 8),
                Text(title, style: TextStyle(color: color, fontSize: 16)),
                const SizedBox(height: 8),
                Text(data, style: TextStyle(color: color, fontSize: 16)),
                const SizedBox(height: 8),
                if ([IotRTDBVariableType.door, IotRTDBVariableType.bell]
                    .contains(type))
                  CupertinoSwitch(
                    value: (snapshot.data is bool) ? snapshot.data : false,
                    onChanged: (value) {
                      updateIotVariableValue(type, value);
                    },
                  ),
              ],
            ),
          );
        });
  }

  void getIotVariableValue(AsyncSnapshot<dynamic> snapshot) {
    switch (type) {
      case IotRTDBVariableType.door:
        data = (snapshot.data as bool) == true ? 'OPEN' : 'CLOSED';
        break;
      case IotRTDBVariableType.bell:
        data = (snapshot.data as bool) == true ? 'RINGING' : 'IDLE';
        break;
      case IotRTDBVariableType.securityStatus:
        data = (snapshot.data as AiAnalysisStatusEnum).name.toUpperCase();
        break;
      // case IotRTDBVariableType.recentCaptures:
      // data = snapshot.data as List<String>;
      // break;
      default:
        data = (snapshot.data as bool) == true ? 'OPEN' : 'CLOSED';
    }
  }

  Stream getIotVariableStream(IotRTDBVariableType type) {
    switch (type) {
      case IotRTDBVariableType.door:
        return iotUsecase.getDoorStatus();
      case IotRTDBVariableType.bell:
        return iotUsecase.getBellStatus();
      case IotRTDBVariableType.securityStatus:
        return iotUsecase.getAiAnalysis();
      // case IotRTDBVariableType.recentCaptures:
      // return iotUsecase.getRecentCaptures();
      default:
        return iotUsecase.getDoorStatus();
    }
  }

  void updateIotVariableValue(IotRTDBVariableType type, bool value) async {
    switch (type) {
      case IotRTDBVariableType.door:
        await iotUsecase.setDoorStatus(value);
        break;
      case IotRTDBVariableType.bell:
        await iotUsecase.setBellStatus(value);
        break;
      default:
        await iotUsecase.setDoorStatus(value);
    }
  }

  Color getColor(AiAnalysisStatusEnum? securityStatus) {
    switch (type) {
      case IotRTDBVariableType.door:
        return Colors.green.withOpacity(0.1);
      case IotRTDBVariableType.bell:
        return Colors.orange.withOpacity(0.1);
      case IotRTDBVariableType.securityStatus:
        return getSecurityBoxColor(securityStatus);
      case IotRTDBVariableType.recentCaptures:
        return Colors.purple.withOpacity(0.1);
    }
  }

  Color getSecurityBoxColor(AiAnalysisStatusEnum? securityStatus) {
    switch (securityStatus) {
      case AiAnalysisStatusEnum.safe:
        return Colors.blue.withOpacity(0.3);
      case AiAnalysisStatusEnum.dubious:
        return Colors.orange.withOpacity(0.3);
      case AiAnalysisStatusEnum.dangerous:
        return Colors.red.withOpacity(0.5);
      default:
        return Colors.blue.withOpacity(0.1);
    }
  }
}
