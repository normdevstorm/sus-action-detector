import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SkeletonDesktop extends StatelessWidget {
  const SkeletonDesktop({super.key, required this.child});

  final StatefulNavigationShell child;

  @override
  Widget build(BuildContext context) {
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
  }
}
