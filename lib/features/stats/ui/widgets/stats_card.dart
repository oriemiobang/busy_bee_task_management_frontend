import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool isPrimary;

  const StatsCard( {
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:  
             AppColors.surfaceDark
        ,
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(
        //   color:  AppColors.borderDark,
        //   width:   1.0
        // ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? Colors.white : Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}