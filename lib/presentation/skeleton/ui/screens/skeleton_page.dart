import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:suspicious_action_detection/app/responisve/responsive_wrapper.dart';
import 'package:suspicious_action_detection/presentation/skeleton/ui/screens/skeleton_desktop.dart';
import 'skeleton_mobile.dart';

class SkeletonPage extends StatefulWidget {
  const SkeletonPage({super.key, required this.title, required this.child});

  final String title;
  final StatefulNavigationShell child;

  @override
  State<SkeletonPage> createState() => _SkeletonPageState();
}

class _SkeletonPageState extends State<SkeletonPage> {
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
    return ResponsiveWrapper(mobileScreen: MobileSkeletonPage(child: widget.child),desktopScreen: SkeletonDesktop( child: widget.child),child: MobileSkeletonPage(child: widget.child),);
  }
}
