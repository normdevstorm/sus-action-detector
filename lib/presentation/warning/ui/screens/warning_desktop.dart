import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WarningDesktop extends StatelessWidget {
  WarningDesktop(
      {Key? key,
      required this.onLevelOneWarningTap,
      required this.onLevelTwoWarningTap})
      : super(key: key);
  final VoidCallback onLevelOneWarningTap;
  final VoidCallback onLevelTwoWarningTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warning'),
      ),
      body: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 32,
          runSpacing: 32,
          children: [
            _buildWarningCard(
              title: 'DUBIOUS',
              iconColor: Colors.amber,
              onTap: onLevelOneWarningTap,
            ),
            _buildWarningCard(
              title: 'DANGEROUS',
              iconColor: Colors.red,
              onTap: onLevelTwoWarningTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard({
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder, size: 128, color: iconColor),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
