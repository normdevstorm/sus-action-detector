import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../widgets/feature_box.dart';

class HomeMobile extends StatelessWidget {
  final Function _navigateToDoor;
  final Function _navigateToBell;
  final Function _navigateToSecurity;
  final VoidCallback _navigateToCaptures;
  final VoidCallback _logout;
  const HomeMobile(
      {super.key,
      required Function navigateToDoor,
      required Function navigateToBell,
      required Function navigateToSecurity,
      required VoidCallback navigateToCaptures,
      required VoidCallback logout})
      : _navigateToDoor = navigateToDoor,
        _navigateToBell = navigateToBell,
        _navigateToSecurity = navigateToSecurity,
        _navigateToCaptures = navigateToCaptures,
        _logout = logout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control Panel')),
      floatingActionButton: FloatingActionButton(
        onPressed: _logout,
        child: const Icon(Icons.logout),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            FeatureBox(
              height: 150,
              isMobile: true,
              type: IotRTDBVariableType.door,
              title: 'Door Control',
              icon: Icons.door_front_door,
              onTap: () => _navigateToDoor,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            FeatureBox(
              height: 150,
              isMobile: true,
              type: IotRTDBVariableType.bell,
              title: 'Bell',
              icon: Icons.notifications,
              onTap: () => _navigateToBell,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            FeatureBox(
              height: 150,
              isMobile: true,
              type: IotRTDBVariableType.securityStatus,
              title: 'Security Status',
              icon: Icons.security,
              onTap: () => _navigateToSecurity,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            FeatureBox(
              height: 150,
              isMobile: true,
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
