import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../app.dart';

class ToastManager {
  ToastManager();

  static showToast(
      {required BuildContext context,
      required String message,
      bool isErrorToast = false}) {
    FToast fToast = FToast();
    fToast.init(context);
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isErrorToast)
            const Icon(
              Icons.clear_outlined,
              color: ColorManager.errorColorLight,
            ),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              message,
              maxLines: 3,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
    fToast.removeQueuedCustomToasts();
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );

    // Custom Toast Position
    // fToast.showToast(
    //     child: toast,
    //     toastDuration: Duration(seconds: 2),
    //     positionedToastBuilder: (context, child) {
    //       return Positioned(
    //         top: 15.h,
    //         child: child,
    //       );
    //     });
  }
}
