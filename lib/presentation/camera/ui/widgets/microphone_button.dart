import 'package:flutter/material.dart';

class MicrophoneButton extends StatelessWidget {
  const MicrophoneButton({super.key, required this.isMicrophoneActive, this.onPressed});

  final bool isMicrophoneActive;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        icon: Icon(
          isMicrophoneActive ? Icons.mic : Icons.mic_off,
          size: 40,
        ),
        onPressed: onPressed,
      ),
    );
  }
}