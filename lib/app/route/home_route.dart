import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/audio/test_stream_audio.dart';
import 'route_define.dart';
part 'home_route.g.dart';

@TypedShellRoute<HomeRoute>(
  routes: [
    TypedGoRoute<HomeScreenRoute>(
        path: "/home", name: RouteDefine.homeScreen, routes: []),
  ],
)
class HomeRoute extends ShellRouteData {
  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return navigator;
  }
}

class HomeScreenRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AudioStreamingScreen();
  }
}
