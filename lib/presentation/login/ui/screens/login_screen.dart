import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:suspicious_action_detection/app/managers/toast_manager.dart';
import 'package:suspicious_action_detection/app/responisve/responsive_wrapper.dart';
import 'package:suspicious_action_detection/domain/iot/usecase/iot_usecase.dart';

import '../../../../app/route/route_define.dart';
import 'login_desktop.dart';
import 'login_mobile.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final IotUsecase iotUsecase = IotUsecase();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
        mobileScreen: LoginMobile(
          usernameController: usernameController,
          passwordController: passwordController,
          iotUsecase: iotUsecase,
          onTap: ()=> handleOnSubmit(context),
        ),
        desktopScreen: LoginDesktop(
          usernameController: usernameController,
          passwordController: passwordController,
          iotUsecase: iotUsecase,
          onTap: ()=> handleOnSubmit(context),
        ),
        child: LoginMobile(
          usernameController: usernameController,
          passwordController: passwordController,
          iotUsecase: iotUsecase,
          onTap:()=> handleOnSubmit(context),
        ));
  }

  void handleOnSubmit(BuildContext context) async {
    final userCredentials = await iotUsecase.signIn(
        usernameController.text, passwordController.text);
    if (userCredentials != null) {
      // Navigate to the next screen
      context.goNamed(RouteDefine.homeScreen);
    } else {
      // Show error message
      ToastManager.showToast(context: context, message: 'Invalid credentials', isErrorToast: true);
    }
  }
}
