// lib/features/dashboard/ui/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/features/calender/ui/calender_screen.dart';
import 'package:frontend/features/profile/ui/settings_screen.dart';
import 'package:frontend/features/stats/ui/stats_screen.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/features/dashboard/ui/widgets/custom_bottom_nav.dart';
import 'package:frontend/features/dashboard/ui/widgets/dashboard_header.dart';
import 'package:frontend/features/dashboard/ui/widgets/date_selector.dart';
import 'package:frontend/features/dashboard/ui/widgets/task_card.dart';
import 'package:frontend/features/dashboard/state/tasks_provider.dart';
import 'package:frontend/features/auth/state/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {


  @override
  void initState() {
    super.initState();
    // Preload tasks when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TasksProvider>().ensureTasksLoaded();
      }
    });
  }

  Future<void> _refreshTasks() async {
    try {
      await context.read<TasksProvider>().fetchTasks(refresh: true);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Refresh failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
        final taskProvider = context.watch<TasksProvider>();
    return SafeArea(
      child: Scaffold(
        body:  taskProvider.currentIndex  == 1? CalendarScreen() : taskProvider.currentIndex == 2? StatsScreen() : taskProvider.currentIndex == 3? AccountSettingsScreen() : Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // 👤 Header with user info (safe access)
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final userName = authProvider.user?.name ?? 'Guest';
                  print( authProvider.user?.imageUrl);
                  return DashboardHeader(
                    userName: userName,
                    // userImage:  authProvider.user!.imageUrl,
                    userImage:  authProvider.user?.imageUrl ?? '',
                  );
                },
              ),
              const SizedBox(height: 20),
              
              const DateSelector(),
              const SizedBox(height: 20),
              
              // Tasks header with counter
              Consumer<TasksProvider>(
                builder: (context, tasksProvider, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Tasks',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(89, 33, 149, 243),
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Text(
                              '${tasksProvider.tasks.length} Tasks',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              
              //  Task list with all states
              Expanded(
                child: Consumer<TasksProvider>(
                  builder: (context, tasksProvider, child) {
                    // 1️ Cache loading state (show skeleton)
                    if (tasksProvider.isLoadingFromCache && tasksProvider.tasks.isEmpty) {
                      return _buildCacheLoadingState();
                    }
                    
                    // 2️ Error state
                    if (tasksProvider.error != null && tasksProvider.tasks.isEmpty) {
                      return _buildErrorState(tasksProvider);
                    }
                    
                    // 3️ Empty state
                    if (tasksProvider.tasks.isEmpty && !tasksProvider.isLoading) {
                      return _buildEmptyState();
                    }
                    
                    // 4️ Main task list
                    return RefreshIndicator(
                      onRefresh: _refreshTasks,
                      child: Column(
                        children: [
                          // Cache refresh indicator
                          if (tasksProvider.isLoadingFromCache && tasksProvider.tasks.isNotEmpty)
                            _buildCacheRefreshBanner(),
                          
                          // Task list
                          Expanded(
                            child: ListView.builder(
                              itemCount: tasksProvider.tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasksProvider.tasks[index];
                             
                                return // In DashboardScreen's ListView.builder:
                                TaskCard(
                                  isHome: true,
                                  key: ValueKey(task.id),
                                  task: task,
                                  onTaskToggle: () => tasksProvider.toggleTaskStatus(task.id),
                                  onSubTaskToggle: (subTaskId) => 
                                      tasksProvider.toggleSubTaskStatus(
                                        taskId: task.id,
                                        subTaskId: subTaskId,
                                      ),
                                  onDelete: () => tasksProvider.deleteTask(task.id),
                                  // Optional callbacks:
                                  // onEdit: () => _navigateToEdit(task.id),
                                  
                                  onUpdate: () => context.pushNamed('editTask', pathParameters: {'id': task.id.toString()}, extra: task),
                                );
                                                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: taskProvider.currentIndex,
          onTap: (index) => taskProvider.setCurrentIndex(index),
        ),
      ),
    );
  }

  //  Cache loading state
  Widget _buildCacheLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator.adaptive(),
          SizedBox(height: 16),
          Text(
            'Loading from cache...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  //  Error state with retry actions
  Widget _buildErrorState(TasksProvider tasksProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          const Text(
            'Failed to load tasks',
            style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              tasksProvider.error ?? 'Please check your internet connection',
              style: TextStyle(color: Colors.grey[500], fontSize: 14, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => context.read<TasksProvider>().fetchTasks(refresh: true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Retry'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => context.read<TasksProvider>().ensureTasksLoaded(),
                child: const Text('Use Cached Data'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //  Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No tasks yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first task to get started',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to create task screen
              // Navigator.push(context, MaterialPageRoute(builder: (_) => CreateTaskScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Create Your First Task'),
          ),
        ],
      ),
    );
  }

  // 📡 Cache refresh banner
  Widget _buildCacheRefreshBanner() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.blue.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_download, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            'Updating from server...',
            style: TextStyle(color: Colors.blue[800], fontSize: 12),
          ),
        ],
      ),
    );
  }
}