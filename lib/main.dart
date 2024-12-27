import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
//TODO: UNCOMMENT THESE LINES TO BUILD WEB PLATFORM
// import 'dart:io' show Platform;
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart' show WebViewPlatform ;
// import 'package:webview_flutter_web/webview_flutter_web.dart' show WebWebViewPlatform;
import 'package:window_manager/window_manager.dart';
import 'app/responisve/layout_utils.dart';
import 'app/route/app_routing.dart';
import 'firebase_options.dart';

void main() async {
  //create before runApp method to wrap all the procedures
  WidgetsFlutterBinding.ensureInitialized();
  //TODO: UNCOMMENT THESE LINES TO BUILD WEB PLATFORM
  // if(kIsWeb && !(Platform.isWindows || Platform.isAndroid)) {
  //     WebViewPlatform.instance = WebWebViewPlatform();
  // }

  windowManager.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('vi', 'VN')],
        path: 'assets/resources/langs/langs.csv',
        assetLoader: CsvAssetLoader(),
        startLocale: const Locale('vi', 'VN'),
        useFallbackTranslations: true,
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    MaterialApp mainApp = MaterialApp.router(
      builder: FToastBuilder(),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      title: 'Flutter Demo',
      themeMode: ThemeMode.light,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light().copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      })),
      routerConfig: AppRouting.shellRouteConfig,
      debugShowCheckedModeBanner: false,
    );

    return LayoutBuilder(
      builder: (context, constraints) => ScreenUtilInit(
        designSize: LayoutUtils.getDeviceSize(constraints),
        useInheritedMediaQuery: true,
        builder: (context, child) => Directionality(
          textDirection: ui.TextDirection.ltr,
          child: mainApp,
        ),
        child: mainApp,
      ),
    );
  }
}
