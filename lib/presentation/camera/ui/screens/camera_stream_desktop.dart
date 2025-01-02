import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suspicious_action_detection/presentation/camera/ui/widgets/microphone_button.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:async';

class CameraStreamDesktop extends StatefulWidget {
  const CameraStreamDesktop({required this.url, Key? key}) : super(key: key);
  final String url;

  @override
  _CameraStreamDesktopState createState() => _CameraStreamDesktopState();
}

class _CameraStreamDesktopState extends State<CameraStreamDesktop> {
  bool _isMicrophoneActive = false;
  final _windowWebviewController = WebviewController();
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Optionally initialize the webview environment using
    // a custom user data directory
    // and/or a custom browser executable directory
    // and/or custom chromium command line flags
    //await WebviewController.initializeEnvironment(
    //    additionalArguments: '--show-fps-counter');

    try {
      await _windowWebviewController.initialize();
      _subscriptions.add(_windowWebviewController.url.listen((url) {}));
      _subscriptions.add(_windowWebviewController
          .containsFullScreenElementChanged
          .listen((flag) {
        debugPrint('Contains fullscreen element: $flag');
        windowManager.setFullScreen(flag);
      }));

      await _windowWebviewController.setBackgroundColor(Colors.transparent);
      await _windowWebviewController
          .setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _windowWebviewController.loadUrl(widget.url);

      if (!mounted) return;
      setState(() {});
    } on PlatformException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text('Error'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code: ${e.code}'),
                      Text('Message: ${e.message}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: Text('Continue'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10.r),
            ),
            width: 800.w,
            height: 700.h,
            child: Webview(
              width: MediaQuery.of(context).size.width * 0.7,
              _windowWebviewController,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
              child: MicrophoneButton(
            isMicrophoneActive: _isMicrophoneActive,
            onPressed: _handleMicrophone,
          )),
        ),
      ],
    );
  }

  void _handleMicrophone() {
    setState(() {
      _isMicrophoneActive = !_isMicrophoneActive;
    });
    //TODO: Add microphone handling logic here
  }
}
