import 'package:flutter/material.dart';
import 'package:suspicious_action_detection/app/responisve/responsive_wrapper.dart';
import 'dart:io';

import 'home_desktop.dart';
import 'home_mobile.dart';
import 'home_web.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
        mobileScreen: HomeMobile(
            navigateToBell: _navigateToBell,
            navigateToCaptures: _navigateToCaptures,
            navigateToDoor: _navigateToDoor,
            navigateToSecurity: _navigateToSecurity),
        desktopScreen: HomeDesktop(
            navigateToBell: _navigateToBell,
            navigateToCaptures: _navigateToCaptures,
            navigateToDoor: _navigateToDoor,
            navigateToSecurity: _navigateToSecurity),
        child: HomeMobile(
            navigateToBell: _navigateToBell,
            navigateToCaptures: _navigateToCaptures,
            navigateToDoor: _navigateToDoor,
            navigateToSecurity: _navigateToSecurity));
  }

  void _navigateToDoor(BuildContext context) {
    // Navigation implementation
    return;
  }

  void _navigateToBell(BuildContext context) {}

  void _navigateToSecurity(BuildContext context) {}

  void _navigateToCaptures(BuildContext context) {}
  // ... other navigation methods
}
