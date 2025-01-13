import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:suspicious_action_detection/presentation/skeleton/ui/screens/skeleton_page.dart';

import '../../../../app/app.dart';
import '../../../../domain/iot/usecase/iot_usecase.dart';

class SkeletonDesktop extends StatelessWidget {
  SkeletonDesktop(
      {super.key,
      required this.child,
      required this.warningLevelNotifier,
      required this.isShowingDialog});

  final StatefulNavigationShell child;
  final IotUsecase iotUsecase = IotUsecase();
  final ValueNotifier<WarningLevelEnum> warningLevelNotifier;
  final ValueNotifier<bool> isShowingDialog;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: iotUsecase.getAiAnalysis(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final WarningLevelEnum? warningLevel = snapshot.data;
            if ([WarningLevelEnum.dangerous, WarningLevelEnum.dubious]
                    .contains(warningLevel) &&
                warningLevelNotifier.value != warningLevel &&
                !isShowingDialog.value) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // if (!isShowingDialog.value) {
                isShowingDialog.value = true;
                showDialog(
                    context: context,
                    builder: (context) => CustomAlerDialog(
                          title: "${warningLevel?.name.toUpperCase()} ALERT",
                          body:
                              "Detected ${warningLevel?.name} object in front of your house gate !!!",
                        )).then((value) {
                  isShowingDialog.value = false;
                });
                // }
              });
            }
                            warningLevelNotifier.value =
                    warningLevel ?? WarningLevelEnum.safe;
          }
          return Scaffold(
            body: child,
            appBar: AppBar(
              leading: Builder(
                builder: (context) {
                  return Container(
                    margin: const EdgeInsets.all(5),
                    child: IconButton(
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(EdgeInsets.all(5)),
                        backgroundColor: WidgetStateProperty.all(Colors.blue),
                      ),
                      tooltip: 'Menu',
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  );
                },
              ),
            ),
            drawer: Drawer(
              clipBehavior: Clip.antiAlias,
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Builder(builder: (context) {
                          return IconButton(
                              alignment: Alignment.topLeft,
                              onPressed: () {
                                Scaffold.of(context).closeDrawer();
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                size: 30.r,
                              ));
                        }),
                        10.horizontalSpace,
                        Text(
                          'Suspicious Action Detector',
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('Home'),
                    onTap: () {
                      child.goBranch(0);
                    },
                  ),
                  ListTile(
                    title: const Text('Camera'),
                    onTap: () {
                      child.goBranch(1);
                    },
                  ),
                  ListTile(
                    title: const Text('Profile'),
                    onTap: () {
                      child.goBranch(2);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
