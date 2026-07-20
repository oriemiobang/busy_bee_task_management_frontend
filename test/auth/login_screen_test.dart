// test/auth/login_screen_test.dart
//
// Widget tests for LoginScreen.
// Tests verify key UI elements render correctly and form validation works.
// Uses a mock AuthProvider to avoid real network calls.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/auth/state/auth_provider.dart';
import 'package:frontend/features/auth/ui/login_screen.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Wraps LoginScreen with the minimal context it needs:
/// - A [Provider<AuthProvider>] with the given repository.
/// - A [GoRouter] that avoids real navigation.
Widget _buildTestWidget(MockAuthRepository mockRepo) {
  final authProvider = AuthProvider(mockRepo);

  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const LoginScreen(),
        ),
      ),
      // Stub destination after login so navigation does not crash tests
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const Scaffold(body: Text('Dashboard')),
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
    theme: ThemeData.dark(),
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  // ---------------------------------------------------------------------------
  // Rendering
  // ---------------------------------------------------------------------------
  group('LoginScreen rendering', () {
    testWidgets('shows key UI elements', (tester) async {
      await tester.pumpWidget(_buildTestWidget(mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue to your account'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
    });

    testWidgets('has email and password text fields', (tester) async {
      await tester.pumpWidget(_buildTestWidget(mockRepo));
      await tester.pumpAndSettle();

      // Two text fields: email + password
      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  });

  // ---------------------------------------------------------------------------
  // Form Validation
  // ---------------------------------------------------------------------------
  group('Form validation', () {
    testWidgets('shows validation error when fields are empty', (tester) async {
      await tester.pumpWidget(_buildTestWidget(mockRepo));
      await tester.pumpAndSettle();

      // Tap Sign In without filling in any fields
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('shows invalid email error for malformed email', (tester) async {
      await tester.pumpWidget(_buildTestWidget(mockRepo));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).first, 'not-an-email');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Login flow
  // ---------------------------------------------------------------------------
  group('Login flow', () {
    testWidgets('calls authProvider.login with form values', (tester) async {
      when(() => mockRepo.login(
            email: 'user@example.com',
            password: 'secret123',
          )).thenAnswer((_) async => AuthResponse(
            user: UserModel(
              id: '1',
              name: 'Test',
              email: 'user@example.com',
              authProvider: 'email',
              imageUrl: '',
            ),
            accessToken: 'fake.token',
            refreshToken: 'fake.refresh',
          ));

      await tester.pumpWidget(_buildTestWidget(mockRepo));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).first, 'user@example.com');
      await tester.enterText(
          find.byType(TextFormField).last, 'secret123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      verify(() => mockRepo.login(
            email: 'user@example.com',
            password: 'secret123',
          )).called(1);
    });
  });
}
