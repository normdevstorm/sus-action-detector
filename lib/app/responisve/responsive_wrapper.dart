import 'package:flutter/material.dart';

import 'layout_utils.dart';

enum ScreenType {
  mobile,
  // tablet,
  desktop
}

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final Widget? mobileScreen;
  // final Widget? tabletScreen;
  final Widget? desktopScreen;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.mobileScreen,
    // this.tabletScreen,
    this.desktopScreen,
  });

  // static const double kMobileMaxWidth = 480;
  // static const double kTabletMaxWidth = 768;
  // static const double kDesktopMinWidth = 1024;

  static ScreenType getScreenType(BoxConstraints constraints) {
    if (LayoutUtils.isMobile(constraints)) {
      return ScreenType.mobile;
    } 
    // else if (LayoutUtils.isTablet(constraints)) {
    //   return ScreenType.mobile;
    // }
     else {
      return ScreenType.desktop;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = getScreenType(constraints);

        switch (screenType) {
          case ScreenType.mobile:
            return mobileScreen ?? child;
          // case ScreenType.tablet:
          //   return tabletScreen ?? child;
          case ScreenType.desktop:
            return desktopScreen ?? child;
        }
      },
    );
  }
}
