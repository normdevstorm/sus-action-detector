import 'package:flutter/material.dart';
import 'package:suspicious_action_detection/presentation/camera/ui/widgets/microphone_button.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class CameraStreamWeb extends StatefulWidget {
  final String streamUrl;
  const CameraStreamWeb({super.key, required this.streamUrl});

  @override
  State<CameraStreamWeb> createState() => _CameraStreamWebState();
}

class _CameraStreamWebState extends State<CameraStreamWeb> {
  bool isMicrophoneActive = false;
  final PlatformWebViewController _controller = PlatformWebViewController(
    const PlatformWebViewControllerCreationParams(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controller.loadRequest(
        LoadRequestParams(
          method: LoadRequestMethod.get,
          uri: Uri.parse(widget.streamUrl),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: <Widget>[
      Expanded(
        child: PlatformWebViewWidget(
          PlatformWebViewWidgetCreationParams(controller: _controller),
        ).build(context),
      ),
      MicrophoneButton(
        isMicrophoneActive: isMicrophoneActive,
        onPressed: () {
          setState(() {
            isMicrophoneActive = !isMicrophoneActive;
          });
          // Add microphone handling logic here
        },
      )
    ])));
  }
}
