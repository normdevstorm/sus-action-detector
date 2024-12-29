import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../widgets/feature_box.dart';

class HomeMobile extends StatelessWidget {
  final Function _navigateToDoor;
  final Function _navigateToBell;
  final Function _navigateToSecurity;
  final VoidCallback _navigateToCaptures;
  const HomeMobile(
      {super.key,
      required Function navigateToDoor,
      required Function navigateToBell,
      required Function navigateToSecurity,
      required VoidCallback navigateToCaptures})
      : _navigateToDoor = navigateToDoor,
        _navigateToBell = navigateToBell,
        _navigateToSecurity = navigateToSecurity,
        _navigateToCaptures = navigateToCaptures;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control Panel')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            FeatureBox(
              type: IotRTDBVariableType.door,
              title: 'Door Control',
              icon: Icons.door_front_door,
              onTap: () => _navigateToDoor,
              color: Colors.green,
            ),
            FeatureBox(
              type: IotRTDBVariableType.bell,
              title: 'Bell',
              icon: Icons.notifications,
              onTap: () => _navigateToBell,
              color: Colors.orange,
            ),
            FeatureBox(
              type: IotRTDBVariableType.securityStatus,
              title: 'Security Status',
              icon: Icons.security,
              onTap: () => _navigateToSecurity,
              color: Colors.red,
            ),
            FeatureBox(
              type: IotRTDBVariableType.recentCaptures,
              title: 'Recent Captures',
              icon: Icons.photo_library,
              onTap: _navigateToCaptures,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}
