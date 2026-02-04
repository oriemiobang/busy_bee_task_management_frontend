import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool isDangerous;
  final VoidCallback onTap;

  const SettingsItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.isDangerous = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Icon(
        icon,
        color: isDangerous ? Colors.red : AppColors.primary,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDangerous ? Colors.red : Colors.white,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      tileColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}