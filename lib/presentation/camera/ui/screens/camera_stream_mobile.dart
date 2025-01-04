import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CameraStreamMobile extends StatefulWidget {
  final String streamUrl;
  const CameraStreamMobile({Key? key, required this.streamUrl})
      : super(key: key);

  @override
  State<CameraStreamMobile> createState() => _CameraStreamMobileState();
}

class _CameraStreamMobileState extends State<CameraStreamMobile> {
  late final WebViewController _webViewController;
  bool _isMicrophoneActive = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeWebView();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _webViewController.reload();
      },
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                color: Colors.black,
                child: WebViewWidget(
                  controller: _webViewController,
                ),
              ),
            ),
            // Expanded(
            //   flex: 1,
            //   child: Center(
            //       child: MicrophoneButton(
            //     isMicrophoneActive: _isMicrophoneActive,
            //     onPressed: _handleMicrophone,
            //   )),
            // ),
          ],
        ),
      ),
    );
  }

  void _handleMicrophone() {
    setState(() {
      _isMicrophoneActive = !_isMicrophoneActive;
    });
    //TODO: Add microphone handling logic here
  }

  void _initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;

    params = const PlatformWebViewControllerCreationParams();

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.streamUrl));

    _webViewController = controller;
  }
}
