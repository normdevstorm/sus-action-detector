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

  // Widget _buildDefaultLayout() {
  //   return Column(
  //     children: [
  //       Expanded(
  //         flex: 4,
  //         child: Container(
  //           color: Colors.black,
  //           child: WebView(
  //             initialUrl: 'YOUR_CAMERA_STREAM_URL',
  //             javascriptMode: JavascriptMode.unrestricted,
  //           ),
  //         ),
  //       ),
  //       Expanded(
  //         flex: 1,
  //         child: Center(
  //           child: IconButton(
  //             icon: Icon(
  //               _isMicrophoneActive ? Icons.mic : Icons.mic_off,
  //               size: 40,
  //             ),
  //             onPressed: () {
  //               setState(() {
  //                 _isMicrophoneActive = !_isMicrophoneActive;
  //               });
  //               // Add microphone handling logic here
  //             },
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
    //TODO: create a specific screen for web using in_app webview
    return CameraStreamWeb(
        streamUrl: "https://inappwebview.dev/docs/intro/#setup-web",
        );
  }
}
