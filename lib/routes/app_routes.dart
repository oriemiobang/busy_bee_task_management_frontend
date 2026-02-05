// lib/routes/app_routes.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/auth/state/auth_provider.dart';
import 'package:frontend/features/dashboard/ui/dashboard_screen.dart';
import 'package:frontend/features/profile/ui/update_password.dart';
// import 'package:frontend/features/dashboard/ui/screens/dashboard_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/auth/ui/login_screen.dart';
import 'package:frontend/features/auth/ui/register_screen.dart';
import 'package:frontend/features/auth/ui/forgot_password_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String changePassword = '/account-password';

  // ✅ Protected routes (require authentication)
  static final _protectedRoutes = [dashboard];
  
  // ✅ Auth routes (should NOT redirect when user is ON these screens)
  static final _authRoutes = [login, register, forgotPassword];

  static GoRouter router(BuildContext context) {
    return GoRouter(
      initialLocation: splash,
      redirect: (context, state) => _redirectLogic(context, state),
      routes: [
        GoRoute(
          path: changePassword,
          name: 'account-password',
          builder: (context, state) => const ChangePassword(),
        ),
        GoRoute(
          path: splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: register,
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: forgotPassword,
          name: 'forgotPassword',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: dashboard,
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
      errorBuilder: (context, state) => _ErrorScreen(state: state),
    );
  }

// lib/routes/app_routes.dart
static String? _redirectLogic(BuildContext context, GoRouterState state) {
  final authProvider = context.read<AuthProvider?>();
  final location = state.uri.toString();

  // Block ALL navigation until initialized (only allow splash)
  if (authProvider == null || !authProvider.isInitialized) {
    return location == splash ? null : splash;
  }

  final isAuthenticated = authProvider.isAuthenticated;

  // Authenticated users: block auth routes → dashboard
  if (isAuthenticated) {
    if (location == splash || 
        location == login || 
        location == register || 
        location == forgotPassword) {
      return dashboard;
    }
    return null; // Allow all other routes
  }

  // Unauthenticated users: block protected routes → login
  if (location == dashboard || location == splash) {
    return login;
  }
  
  // ✅ CRITICAL: ALLOW auth routes to render (no redirect!)
  return null;
}
}
// lib/routes/app_routes.dart - REPLACE SplashScreen with this:
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Check auth state AFTER widget is mounted with providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final authProvider = context.read<AuthProvider>();
      
      // If already initialized, redirect immediately
      if (authProvider.isInitialized) {
        _performRedirect(authProvider);
      } else {
        // Listen for initialization completion
        authProvider.addListener(_onAuthStateChanged);
      }
    });
  }

  void _onAuthStateChanged() {
    if (!mounted) return;
    
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isInitialized) {
      authProvider.removeListener(_onAuthStateChanged);
      _performRedirect(authProvider);
    }
  }

  void _performRedirect(AuthProvider authProvider) {
    if (!mounted) return;
    
    if (authProvider.isAuthenticated) {
      context.go(AppRoutes.dashboard);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInitialized = context.watch<AuthProvider>().isInitialized;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            if (!isInitialized) ...[
              const CircularProgressIndicator.adaptive(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
              const SizedBox(height: 16),
              Text(
                'Initializing app...',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final GoRouterState state;
  
  const _ErrorScreen({required this.state});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider?>();
    final destination = authProvider?.isAuthenticated == true 
        ? AppRoutes.dashboard 
        : AppRoutes.login;
    
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.error_outline, size: 72, color: Colors.red),
              ),
              const SizedBox(height: 24),
              Text(
                'Page Not Found',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.error?.toString() ?? 'The requested page could not be found.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: () => context.go(destination),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    authProvider?.isAuthenticated == true 
                        ? 'Go to Dashboard' 
                        : 'Go to Login',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

