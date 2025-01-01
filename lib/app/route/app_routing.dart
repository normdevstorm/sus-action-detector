import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:suspicious_action_detection/app/route/home_route.dart';
import 'package:suspicious_action_detection/app/route/route_define.dart';
import 'package:suspicious_action_detection/presentation/warning/ui/screens/warning_screen.dart';

import '../../presentation/camera/ui/screens/camera_stream.dart';
import '../../presentation/skeleton/ui/screens/skeleton_page.dart';
import '../../presentation/splash/ui/screens/splash_screen.dart';
import 'global_keys.dart';

class AppRouting {
  static final ValueNotifier<bool> navBarVisibleNotifier =
      ValueNotifier<bool>(true);
  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();
  static GoRouter get shellRouteConfig => _shellRoute;
  static final GoRouter _shellRoute = GoRouter(
      observers: [
        ChuckerFlutter.navigatorObserver,
        routeObserver,
      ],
      navigatorKey: globalRootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
            parentNavigatorKey: globalRootNavigatorKey,
            path: '/',
            builder: (context, state) => const SplashScreen()),
        //TODO: add authentication route
        // StatefulShellRoute.indexedStack(
        //   parentNavigatorKey: globalRootNavigatorKey,
        //   branches: <StatefulShellBranch>[
        //     StatefulShellBranch(
        //       routes: [],
        //       navigatorKey: rootNavigatorAuthentication,
        //     )
        //   ],
        //   builder: (context, state, navigationShell) => navigationShell,
        // ),
        StatefulShellRoute.indexedStack(
            restorationScopeId: 'root',
            parentNavigatorKey: globalRootNavigatorKey,
            builder: (context, state, navigationShell) =>
                SkeletonPage(title: "Skeleton page", child: navigationShell),
            branches: <StatefulShellBranch>[
              StatefulShellBranch(
                  navigatorKey: rootNavigatorHome,
                  routes: <RouteBase>[$homeRoute]),
              StatefulShellBranch(
                  navigatorKey: rootNavigatorCamera,
                  routes: <RouteBase>[
                    GoRoute(
                        name: RouteDefine.camera,
                        path: '/camera',
                        builder: (context, state) {
                          return CameraStream(
                            streamUrl: "http://188.166.177.199/client.html",
                          );
                        })
                  ],
                  preload: true),
              StatefulShellBranch(
                  navigatorKey: rootNavigatorSettings,
                  routes: <RouteBase>[
                    GoRoute(
                        name: RouteDefine.settings,
                        path: '/settings',
                        builder: (context, state) {
                          return WarningScreen();
                        })
                  ]),
            ])
      ]);
}
