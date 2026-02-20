import 'package:flutter/material.dart';

class TaskActions extends StatelessWidget {
  final VoidCallback onPriority;
  final VoidCallback onTags;
  final VoidCallback onAssign;

  const TaskActions({
    super.key,
    required this.onPriority,
    required this.onTags,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.flag,
          label: 'Priority',
          onPressed: onPriority,
        ),
        _buildActionButton(
          icon: Icons.tag,
          label: 'Tags',
          onPressed: onTags,
        ),
        _buildActionButton(
          icon: Icons.person,
          label: 'Assign',
          onPressed: onAssign,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.blue,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}