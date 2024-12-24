import 'package:flutter/material.dart';

class LayoutUtils {
  // Width breakpoints
  static const double kMobileMaxWidth = 480;
  static const double kDesktopMinWidth = 1024;

  // Height breakpoints (currently unused)
  static const double kMobileMinHeight = 640;
  static const double kDesktopMinHeight = 900;

  // Device sizes
  static const Size kMobileSize = Size(375, 812);
  static const Size kDesktopSize = Size(1440, 900);

  /// Returns the design size based on the current constraints
  static Size getDeviceSize(BoxConstraints constraints) {
    if (isMobile(constraints)) {
      return kMobileSize;
    } else if (isDesktop(constraints)) {
      return kDesktopSize;
    }
    return kMobileSize; // Default to mobile size
  }

  /// Checks if the current screen size is considered mobile
  static bool isMobile(BoxConstraints constraints) {
    return constraints.maxWidth <= kMobileMaxWidth;
  }

  /// Checks if the current screen size is considered desktop
  static bool isDesktop(BoxConstraints constraints) {
    return constraints.maxWidth >= kDesktopMinWidth;
  }
}
