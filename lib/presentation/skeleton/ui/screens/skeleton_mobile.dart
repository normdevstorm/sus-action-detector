import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileSkeletonPage extends StatelessWidget {
  const MobileSkeletonPage({
    super.key,
    required this.child,
  });

  final StatefulNavigationShell child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
          enableFeedback: false,
          currentIndex:child.currentIndex,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          onTap: (value) => child.goBranch(value),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt_rounded), label: "Camera"),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: "Profile"),
          ]),
    );
  }
}