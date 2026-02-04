import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/routes/app_routes.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  
  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  
  static const List<String> _routes = [
    AppRoutes.dashboard,
    // AppRoutes.tasks,
    // AppRoutes.profile,
  ];
  
  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.task),
      label: 'Tasks',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_routes[index]);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _navItems,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

// Update your protected routes to use MainLayout:
/*
GoRoute(
  path: '/dashboard',
  pageBuilder: (context, state) => buildPageWithDefaultTransition(
    context: context,
    state: state,
    child: MainLayout(child: const DashboardScreen()),
  ),
),
*/