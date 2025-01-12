import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:suspicious_action_detection/app/responisve/responsive_wrapper.dart';
import 'package:suspicious_action_detection/presentation/skeleton/ui/screens/skeleton_desktop.dart';
import '../../../../app/app.dart';
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
  final ValueNotifier<WarningLevelEnum> warningLevelNotifier = ValueNotifier(WarningLevelEnum.safe);
  final ValueNotifier<bool> isShowingDialog = ValueNotifier(false);
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((message) async {
      showDialog(
          context: context,
          builder: (context) => CustomAlerDialog(title: message.notification?.title, body: message.notification?.body,));
    });
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
            if (snapshot.data == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.goNamed(RouteDefine.login);
              });
            }
          }
          return ResponsiveWrapper(
            mobileScreen: MobileSkeletonPage(child: widget.child),
            desktopScreen: SkeletonDesktop(warningLevelNotifier: warningLevelNotifier, isShowingDialog: isShowingDialog, child: widget.child),
            child: MobileSkeletonPage(child: widget.child),
          );
        });
  }
}

class CustomAlerDialog extends StatelessWidget {
  const CustomAlerDialog({
    this.title,
    this.body,
    super.key,
  });
final String? title;
final String? body;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
          backgroundColor: Colors.red[100],
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text(
                title ?? '',
                style: TextStyle(
                  color: Colors.red[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            body ?? '',
            style: TextStyle(
              color: Colors.red[900],
              fontSize: 16,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.red, width: 2),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.red[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
                              TextButton(
              onPressed: () { 
                Navigator.of(context).pop();
                context.goNamed(RouteDefine.settings);},
              child: Text(
                'See more',
                style: TextStyle(
                  color: Colors.red[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
  }
}
