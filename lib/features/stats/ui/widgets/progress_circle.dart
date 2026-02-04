import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class ProgressCircle extends StatelessWidget {
  final int percent;
  final String title;
  // final String subtitle;

  const ProgressCircle({
    super.key,
    required this.percent,
    required this.title,
    // required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Stack(
        children: [
          // Background circle
          // CircularProgressIndicator(
          //   value: 0.5,
          //   strokeWidth: 10,
          //   valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          //   backgroundColor: Colors.blue.withOpacity(0.1),
          // ),
          
          // Progress circle
          // CircularProgressIndicator(
          //   value: percent / 100.0,
          //   strokeWidth: 10,
          //   valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          //   backgroundColor: Colors.transparent,
          // ),
          
          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[300],
                  ),
                ),
                // const SizedBox(height: 4),
                // Text(
                //   subtitle,
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: Colors.grey[400],
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}