import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:suspicious_action_detection/domain/iot/usecase/iot_usecase.dart';

import '../../../../app/route/route_define.dart';

class LoginMobile extends StatelessWidget {
  LoginMobile(
      {super.key,
      required this.iotUsecase,
      required this.usernameController,
      required this.passwordController,
      required this.onTap});
  final IotUsecase iotUsecase;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onTap;

  final ValueNotifier<bool> obscureText = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            User? user = snapshot.data;
            if (user != null) {
              context.goNamed(RouteDefine.homeScreen);
            }
          }
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          controller: usernameController,
                        ),
                        const SizedBox(height: 20),
                        ValueListenableBuilder(
                          valueListenable: obscureText,
                          builder: (context, isObscured, child) => TextField(
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(isObscured
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  obscureText.value = !isObscured;
                                },
                              ),
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            obscureText: isObscured,
                            controller: passwordController,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: onTap,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
