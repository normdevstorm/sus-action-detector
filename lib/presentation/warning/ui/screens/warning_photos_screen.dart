import 'package:flutter/material.dart';
import 'package:suspicious_action_detection/app/app.dart';
import 'package:suspicious_action_detection/domain/iot/usecase/iot_usecase.dart';
import '../../../../app/responisve/responsive_wrapper.dart';
import 'warning_photos_mobile.dart';
import 'warning_photos_desktop.dart';

// ignore: must_be_immutable
class WarningPhotosScreen extends StatelessWidget {
  WarningPhotosScreen({super.key, required this.warningLevel});
  final WarningLevelEnum warningLevel;
  final IotUsecase iotUsecase = IotUsecase();
  List<String> warningImageUrls = [];
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
        stream: (warningLevel == WarningLevelEnum.dangerous)
            ? iotUsecase.getWarningLevelTwoImageUrls()
            : iotUsecase.getWarningLevelOneImageUrls(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            _isLoading = false;
          }

          if (snapshot.hasData) {
            warningImageUrls.clear();
            warningImageUrls.addAll(snapshot.data!);
          }

          return ResponsiveWrapper(
            mobileScreen: WarningPhotosMobile(
              isLoading: _isLoading,
              images: warningImageUrls,
            ),
            desktopScreen: WarningPhotosDesktop(
              isLoading: _isLoading,
              images: warningImageUrls,
            ),
            child: WarningPhotosMobile(
              isLoading: _isLoading,
              images: warningImageUrls,
            ),
          );
        });

    // StreamBuilder<List<String>>(
    //   stream: iotUsecase.getWarningLevelTwoImageUrls(),
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       warningImageUrls.clear();
    //       warningImageUrls.addAll(snapshot.data!);
    //     }
    //                 return ListView.builder(
    //         itemCount: warningImageUrls.length,
    //         itemBuilder: (context, index) {
    //           return Image.network(warningImageUrls[index]);
    //         },
    //       );

    //   }
    // ),
  }
}
