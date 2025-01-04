import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:suspicious_action_detection/app/responisve/responsive_wrapper.dart';
import 'package:suspicious_action_detection/presentation/skeleton/ui/screens/skeleton_desktop.dart';
import '../../../../app/route/route_define.dart';
import '../../../../domain/iot/usecase/iot_usecase.dart';
import 'skeleton_mobile.dart';

class SkeletonPage extends StatefulWidget {
  const SkeletonPage({super.key, required this.title, required this.child});

  final String title;
  final StatefulNavigationShell child;

  @override
  State<SkeletonPage> createState() => _SkeletonPageState();
}

class _SkeletonPageState extends State<SkeletonPage> {
  final IotUsecase iotUsecase = IotUsecase();
  @override
  void initState() {
    super.initState();
    //TODO: disable navbar scroll for now
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: iotUsecase.userChanges(),
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.done) {
          //   if (snapshot.data != null) {
          //     if (snapshot.data is main_platform_firebase_auth.User) {
          //       main_platform_firebase_auth.User? user = snapshot.data;
          //       if (user == null) {
          //         context.goNamed(RouteDefine.login);
          //       }
          //     } else if (snapshot.data
          //         is windows_platform_firebase_auth_dart.User) {
          //       windows_platform_firebase_auth_dart.User? user = snapshot.data;
          //       if (user == null) {
          //         context.goNamed(RouteDefine.login);
          //       }
          //     }
          //   }
          // } else 
          if (snapshot.connectionState == ConnectionState.active) {
              if(snapshot.data == null){
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.goNamed(RouteDefine.login);
                });
              }
          }
          return ResponsiveWrapper(
            mobileScreen: MobileSkeletonPage(child: widget.child),
            desktopScreen: SkeletonDesktop(child: widget.child),
            child: MobileSkeletonPage(child: widget.child),
          );
        });
  }
}
