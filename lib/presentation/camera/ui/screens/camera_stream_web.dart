import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:suspicious_action_detection/presentation/camera/ui/widgets/microphone_button.dart';

class CameraStreamWeb extends StatefulWidget {
  final String streamUrl;
  const CameraStreamWeb({super.key, required this.streamUrl});

  @override
  State<CameraStreamWeb> createState() => _CameraStreamWebState();
}

class _CameraStreamWebState extends State<CameraStreamWeb> {
  final GlobalKey webViewKey = GlobalKey();
  bool isMicrophoneActive = false;

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true);
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: <Widget>[
      // TextField(
      //   decoration: const InputDecoration(prefixIcon: Icon(Icons.search)),
      //   controller: urlController,
      //   keyboardType: TextInputType.url,
      //   onSubmitted: (value) {
      //     var url = WebUri(value);
      //     if (url.scheme.isEmpty) {
      //       url = WebUri("https://www.google.com/search?q=$value");
      //     }
      //     webViewController?.loadUrl(urlRequest: URLRequest(url: url));
      //   },
      // ),
      Expanded(
        child: Stack(
          children: [
            InAppWebView(
              key: webViewKey,
              // webViewEnvironment: webViewEnvironment,
              initialUrlRequest: URLRequest(url: WebUri(widget.streamUrl)),
              initialSettings: settings,
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {},
              onPermissionRequest: (controller, request) async {
                return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT);
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                // var uri = navigationAction.request.url!;
                return NavigationActionPolicy.CANCEL;
              },
              onLoadStop: (controller, url) async {},
              onReceivedError: (controller, request, error) {},
              onProgressChanged: (controller, progress) {
                if (progress == 100) {}
                setState(() {
                  this.progress = progress / 100;
                });
              },
              onUpdateVisitedHistory: (controller, url, androidIsReload) {
                setState(() {});
              },
              onConsoleMessage: (controller, consoleMessage) {
                if (kDebugMode) {
                  print(consoleMessage);
                }
              },
            ),
            progress < 1.0
                ? LinearProgressIndicator(value: progress)
                : Container(),
          ],
        ),
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
