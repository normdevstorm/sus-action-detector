import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dart/auth.dart' as windows_platform_firebase_auth_dart;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/route/route_define.dart';
import '../../../../domain/iot/usecase/iot_usecase.dart';

class LoginDesktop extends StatelessWidget {
   LoginDesktop({super.key, required this.iotUsecase, required this.usernameController, required this.passwordController, required this.onTap});
  final IotUsecase iotUsecase;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final ValueNotifier<bool> obscureText = ValueNotifier(true);
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data;
          if (user != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.goNamed(RouteDefine.homeScreen);
            });
          }
        }
        return Scaffold(
          body: Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ValueListenableBuilder(
                    valueListenable: obscureText,
                    builder: (context, isObscured, child) =>  TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(isObscured ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            obscureText.value = !isObscured;
                          },
                        ),
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      obscureText: isObscured,
        
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed:onTap,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Stream get stream => kIsWeb ?   FirebaseAuth.instance
  .userChanges() : windows_platform_firebase_auth_dart.FirebaseAuth.instance
  .userChanges();
}
