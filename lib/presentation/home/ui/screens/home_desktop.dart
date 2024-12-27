import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suspicious_action_detection/app/app.dart';

import '../widgets/feature_box.dart';

class HomeDesktop extends StatelessWidget {
  final Function _navigateToDoor;
  final Function _navigateToBell;
  final Function _navigateToSecurity;
  final Function _navigateToCaptures;
  const HomeDesktop(
      {super.key,
      required Function navigateToDoor,
      required Function navigateToBell,
      required Function navigateToSecurity,
      required Function navigateToCaptures})
      : _navigateToDoor = navigateToDoor,
        _navigateToBell = navigateToBell,
        _navigateToSecurity = navigateToSecurity,
        _navigateToCaptures = navigateToCaptures;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Wrap(
              direction: Axis.horizontal,
              // crossAxisCount: 3,
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.spaceAround,
              runAlignment: WrapAlignment.center,
              children: [
                FeatureBox(
                  type: IotRTDBVariableType.door,
                  height: 400,
                  width: 400,
                  title: 'Door Control',
                  icon: Icons.door_front_door,
                  onTap: () => _navigateToDoor,
                  color: Colors.green,
                ),
                FeatureBox(
                  type: IotRTDBVariableType.bell,
                  height: 400,
                  width: 400,
                  title: 'Bell',
                  icon: Icons.notifications,
                  onTap: () => _navigateToBell,
                  color: Colors.orange,
                ),
                FeatureBox(
                  type: IotRTDBVariableType.securityStatus,
                  height: 400,
                  width: 400,
                  title: 'Security Status',
                  icon: Icons.security,
                  onTap: () => _navigateToSecurity,
                  color: Colors.red,
                ),
                FeatureBox(
                  type: IotRTDBVariableType.recentCaptures,
                  height: 400,
                  width: 400,
                  title: 'Recent Captures',
                  icon: Icons.photo_library,
                  onTap: () => _navigateToCaptures(context),
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
