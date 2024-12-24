import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
                      enableFeedback: false,
                      currentIndex: widget.child.currentIndex,
                      selectedItemColor: Colors.blueAccent,
                      unselectedItemColor: Colors.grey,
                      onTap: (value) => widget.child.goBranch(value),
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
