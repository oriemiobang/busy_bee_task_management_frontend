import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String subMessage;

  const EmptyState({
    super.key,
    this.message = 'No tasks scheduled for today',
    this.subMessage = 'Create your first task to stay organized',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.calendar_today, size: 40, color: Color(0xFF6366F1)),
        ),
        const SizedBox(height: 24),
        Text(
          message,
          style: TextStyle(color: Colors.grey[400], fontSize: 18, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subMessage,
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}