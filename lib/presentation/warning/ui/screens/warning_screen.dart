import 'package:flutter/material.dart';
import 'package:suspicious_action_detection/app/app.dart';
import '../../../../app/responisve/responsive_wrapper.dart';
import 'warning_mobile.dart';
import 'warning_desktop.dart';
import 'warning_photos_screen.dart';

class WarningScreen extends StatelessWidget {
  const WarningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      mobileScreen: WarningMobile(onLevelOneWarningTap:()=> onTapLevelOneWarning(context), onLevelTwoWarningTap: ()=> onTapLevelTwoWarning(context)),
      desktopScreen: WarningDesktop(onLevelOneWarningTap:()=> onTapLevelOneWarning(context), onLevelTwoWarningTap: ()=> onTapLevelTwoWarning(context)),
      child: WarningMobile(onLevelOneWarningTap: ()=> onTapLevelOneWarning(context), onLevelTwoWarningTap: ()=> onTapLevelTwoWarning(context)),
    );
  }

  void onTapLevelOneWarning(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WarningPhotosScreen(warningLevel: WarningLevelEnum.dubious,),
      ),
    );
  }

    void onTapLevelTwoWarning(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WarningPhotosScreen(warningLevel: WarningLevelEnum.dangerous,),
      ),
    );
  }
}
