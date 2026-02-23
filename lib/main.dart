// lib/main.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/core/storage/secure_storage.dart';
import 'package:frontend/features/auth/data/auth_api.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/state/auth_provider.dart';
import 'package:frontend/features/calender/state/calender_provier.dart';
import 'package:frontend/features/dashboard/data/tasks_api.dart';
import 'package:frontend/features/dashboard/data/tasks_repository.dart';
import 'package:frontend/features/dashboard/state/tasks_provider.dart';
import 'package:frontend/features/profile/data/account_api.dart';
import 'package:frontend/features/profile/data/account_repository.dart';
import 'package:frontend/features/profile/state/account_provider.dart';
import 'package:frontend/features/stats/data/stats_api.dart';
import 'package:frontend/features/stats/data/stats_repository.dart';
import 'package:frontend/features/stats/state/stats_provoder.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
  url: 'https://zraflqvymigtirrotmko.supabase.co',
  anonKey: 'eeyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpyYWZscXZ5bWlndGlycm90bWtvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA0NTE2MTUsImV4cCI6MjA4NjAyNzYxNX0.wkM6o1muaL6AyEZ9TIZ0NGm9Bzh58KUYaE9Q_7ImpEQ',
);
  
  runApp(
    // CRITICAL: Register dependencies IN CORRECT ORDER (bottom-up)
    MultiProvider(
      providers: [
        // 1. Core dependencies (no dependencies)
        Provider(create: (_) => DioClient()),
        Provider(create: (_) => SecureStorage()),
        
        // 2. APIs (depend on core)
        Provider(create: (context) => AuthApi(context.read<DioClient>())),
        Provider(create: (context) => TasksApi(context.read<DioClient>())),

        // 3. Repositories (depend on APIs + storage)
        Provider(create: (context) => AuthRepository(
          authApi: context.read<AuthApi>(),
          secureStorage: context.read<SecureStorage>(),
        )),
        Provider(create: (context) => TasksRepository(
          context.read<TasksApi>(),
          context.read<SecureStorage>(),
        )),

        // 4. Feature providers (depend on repositories)
        //  Initialize auth immediately at startup
        ChangeNotifierProvider(create: (context) {
          final provider = AuthProvider(context.read<AuthRepository>());
          provider.initialize(); // Start auth check immediately
          return provider;
        }),
        ChangeNotifierProvider(create: (context) => 
          TasksProvider(context.read<TasksRepository>())),

               ChangeNotifierProvider(create: (context) => 
          CalendarProvider(context.read<TasksProvider>())),

          ChangeNotifierProvider(create: (context) => 
          StatsProvider(StatsRepository(
            StatsApi(context.read<DioClient>()),
            context.read<SecureStorage>(),
          )),),

     ChangeNotifierProvider(create: (context) => 
      AccountProvider(AccountRepository(
        AccountApi(context.read<DioClient>()),
        context.read<AuthRepository>(),
        context.read<SecureStorage>(),
      ),),
    ),


    // In main.dart

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //  CRITICAL: Create router HERE where context has providers
    final router = AppRoutes.router(context);

    
    return MaterialApp.router(
      title: 'Productivity App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        // scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}