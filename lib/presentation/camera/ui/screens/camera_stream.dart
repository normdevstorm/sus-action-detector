import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:suspicious_action_detection/presentation/camera/ui/screens/camera_stream_mobile.dart';
import 'package:suspicious_action_detection/presentation/camera/ui/screens/camera_stream_web.dart';

import '../../../../app/responisve/responsive_wrapper.dart';
import 'camera_stream_desktop.dart';

class CameraStream extends StatefulWidget {
  final String streamUrl;
  const CameraStream({super.key, required this.streamUrl});
  @override
  _CameraStreamState createState() => _CameraStreamState();
}

class _CameraStreamState extends State<CameraStream> {
  bool _isMicrophoneActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveWrapper(
        mobileScreen: CameraStreamMobile(
          streamUrl: widget.streamUrl,
        ),
        desktopScreen: kIsWeb
            ? CameraStreamWeb(
                streamUrl: widget.streamUrl,
              )
            : CameraStreamDesktop(
                url: widget.streamUrl,
              ),
        child: CameraStreamMobile(
          streamUrl: widget.streamUrl,
        ),
      ),
    );
  }
}
