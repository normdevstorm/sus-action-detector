import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:suspicious_action_detection/presentation/camera/ui/screens/camera_stream_mobile.dart';
import 'package:suspicious_action_detection/presentation/camera/ui/screens/camera_stream_web.dart';

import '../../../../app/responisve/responsive_wrapper.dart';
import 'camera_stream_desktop.dart';

class CameraStream extends StatefulWidget {
  @override
  _CameraStreamState createState() => _CameraStreamState();
}

class _CameraStreamState extends State<CameraStream> {
  bool _isMicrophoneActive = false;

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: _buildDesktopLayout(),
      mobileScreen: _buildMobileLayout(),
      desktopScreen: kIsWeb ? _buildWebLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return CameraStreamMobile(
      streamUrl: "https://www.earthcam.com/usa/tennessee/nashville/",
    );
  }

  Widget _buildDesktopLayout() {
    return CameraStreamDesktop(
      url: "https://www.earthcam.com/usa/tennessee/nashville/",
    );
  }
}

class _buildWebLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CameraStreamWeb(
        streamUrl: "https://www.earthcam.com/usa/tennessee/nashville/?cam=nashville",
        );
  }
}
