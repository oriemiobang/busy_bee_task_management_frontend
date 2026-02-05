import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/features/auth/state/auth_provider.dart';
import 'package:frontend/features/dashboard/state/tasks_provider.dart';
import 'package:frontend/features/profile/state/account_provider.dart';
import 'package:provider/provider.dart';
// import 'package:frontend/features/account/state/account_provider.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final taskProvider = context.watch<TasksProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = accountProvider.user;

    

    return Column(
      children: [
        // Profile picture with edit button
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                shape: BoxShape.circle,
                image: user?.imageUrl != null
                    ? DecorationImage(
                        // image: NetworkImage(user!.imageUrl!),
                        image: AssetImage('assets/girl1.jpg'),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // User name
        Text(
          authProvider.user!.name ?? 'User',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Divider(),
        SizedBox(height: 5,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(taskProvider.tasks.where((task){
                    return task.status == "COMPLETED";
                  }).length.toString(), 
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.primary),),
                  Text('TASKS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textSecondary),)
                ]
              ),
              Column(
                children: [
                  Text(taskProvider.tasks.isNotEmpty
                      ? (((taskProvider.tasks.where((task) {
                          return task.status == "COMPLETED";
                        }).length / taskProvider.tasks.length) * 100)
                            .round()
                            .toString()
                        ) + '%'
                      : '0',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),),
                  Text('DONE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textSecondary),)
                ]
              ),
              Column(
                children: [
                  Text(taskProvider.tasks.where((task){
                    return task.status != "COMPLETED";
                  }).length.toString(),
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.amber),),
                  Text('PENDING', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textSecondary),)
                ]
              ),
             
            ]
          ),
        )
        // User email
        // Text(
        //   user?.email ?? '',
        //   style: TextStyle(
        //     fontSize: 14,
        //     color: Colors.grey[400],
        //   ),
        // ),
      ],
    );
  }
}