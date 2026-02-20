import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark, 
            // borderRadius: const BorderRadius.only(
            //   topLeft: Radius.circular(20),
            //   topRight: Radius.circular(20),
            // ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildNavItem(icon: Icons.home, label: 'Home', index: 0),
              buildNavItem(icon: Icons.calendar_today, label: 'Calendar', index: 1),
              const SizedBox(width: 60),
              buildNavItem(icon: Icons.show_chart, label: 'Stats', index: 2),
              buildNavItem(icon: Icons.person, label: 'Profile', index: 3),
            ],
          ),
        ),

        // Center FAB
     Positioned(
  top: -35,
  left: MediaQuery.of(context).size.width / 2 - 30,
  child: GestureDetector(
    onTap: () => context.push(AppRoutes.newTask),
    child: Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black, 
          width: 5,
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: AppColors.primary,
        //     blurRadius: 5,
        //     offset: Offset(0, 3),
        //   ),
        // ],
      ),
      child: Icon(
     Icons.add, size: 30, color: Colors.white),
      
    ),
  ),
),

      ],
    );
  }

  Widget buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
