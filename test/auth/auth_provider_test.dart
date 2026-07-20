// test/auth/auth_provider_test.dart
//
// Unit tests for AuthProvider using mocktail to mock AuthRepository.
// Tests focus on state transitions (loading, error, user) for the core auth flows.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/models/user_model.dart';
import 'package:frontend/features/auth/state/auth_provider.dart';

// ─── Fakes & Mocks ───────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}

// ─── Helpers ─────────────────────────────────────────────────────────────────

UserModel _fakeUser({String id = '1', String name = 'Test User'}) => UserModel(
      id: id,
      name: name,
      email: 'test@example.com',
      authProvider: 'email',
      imageUrl: '',
    );

AuthResponse _fakeAuthResponse({bool hasToken = true}) => AuthResponse(
      user: _fakeUser(),
      accessToken: hasToken ? 'fake.jwt.token' : '',
      refreshToken: hasToken ? 'fake.refresh' : '',
    );

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late MockAuthRepository mockRepo;
  late AuthProvider provider;

  setUp(() {
    mockRepo = MockAuthRepository();
    provider = AuthProvider(mockRepo);
  });

  // ---------------------------------------------------------------------------
  // login()
  // ---------------------------------------------------------------------------
  group('login()', () {
    test('sets user and clears loading on success', () async {
      when(() => mockRepo.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => _fakeAuthResponse());

      final calls = <bool>[];
      provider.addListener(() => calls.add(provider.isLoading));

      await provider.login(email: 'test@example.com', password: 'secret');

      expect(provider.isAuthenticated, isTrue);
      expect(provider.user?.email, 'test@example.com');
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('sets error and rethrows on failure', () async {
      when(() => mockRepo.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Invalid credentials'));

      await expectLater(
        () => provider.login(email: 'test@example.com', password: 'wrong'),
        throwsA(isA<Exception>()),
      );

      expect(provider.isAuthenticated, isFalse);
      expect(provider.isLoading, isFalse);
      expect(provider.error, contains('Invalid credentials'));
    });
  });

  // ---------------------------------------------------------------------------
  // register()
  // ---------------------------------------------------------------------------
  group('register()', () {
    test('sets user when registration returns a token', () async {
      when(() => mockRepo.register(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            auth_provider: any(named: 'auth_provider'),
          )).thenAnswer((_) async => _fakeAuthResponse(hasToken: true));

      await provider.register(
        name: 'Test User',
        email: 'test@example.com',
        password: 'secret',
      );

      expect(provider.isAuthenticated, isTrue);
      expect(provider.isLoading, isFalse);
    });

    test('calls login() when registration returns no token', () async {
      when(() => mockRepo.register(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            auth_provider: any(named: 'auth_provider'),
          )).thenAnswer((_) async => _fakeAuthResponse(hasToken: false));

      // Auto-login call
      when(() => mockRepo.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => _fakeAuthResponse(hasToken: true));

      await provider.register(
        name: 'Test User',
        email: 'test@example.com',
        password: 'secret',
      );

      verify(() => mockRepo.login(
            email: 'test@example.com',
            password: 'secret',
          )).called(1);

      expect(provider.isAuthenticated, isTrue);
    });

    test('sets error on failure', () async {
      when(() => mockRepo.register(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            auth_provider: any(named: 'auth_provider'),
          )).thenThrow(Exception('Email already in use'));

      await expectLater(
        () => provider.register(
          name: 'Test',
          email: 'used@example.com',
          password: 'pass',
        ),
        throwsA(isA<Exception>()),
      );

      expect(provider.isAuthenticated, isFalse);
      expect(provider.error, contains('Email already in use'));
    });
  });

  // ---------------------------------------------------------------------------
  // checkAuthStatus()
  // ---------------------------------------------------------------------------
  group('checkAuthStatus()', () {
    test('sets user when token is valid', () async {
      when(() => mockRepo.isLoggedIn()).thenAnswer((_) async => true);
      when(() => mockRepo.getCurrentUser())
          .thenAnswer((_) async => _fakeUser());

      await provider.checkAuthStatus();

      expect(provider.isAuthenticated, isTrue);
      expect(provider.isLoading, isFalse);
    });

    test('clears user when not logged in', () async {
      when(() => mockRepo.isLoggedIn()).thenAnswer((_) async => false);

      await provider.checkAuthStatus();

      expect(provider.isAuthenticated, isFalse);
      expect(provider.isLoading, isFalse);
    });

    test('sets error (but does not throw) when repository throws', () async {
      when(() => mockRepo.isLoggedIn())
          .thenThrow(Exception('Storage error'));

      // checkAuthStatus should not rethrow — it sets the error state
      await expectLater(provider.checkAuthStatus(), completes);

      expect(provider.isAuthenticated, isFalse);
      expect(provider.error, contains('Storage error'));
    });
  });

  // ---------------------------------------------------------------------------
  // logout()
  // ---------------------------------------------------------------------------
  group('logout()', () {
    test('clears user state after logout', () async {
      // First, log in
      when(() => mockRepo.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => _fakeAuthResponse());
      await provider.login(email: 'test@example.com', password: 'secret');
      expect(provider.isAuthenticated, isTrue);

      // Then, log out
      when(() => mockRepo.logout()).thenAnswer((_) async {});
      await provider.logout();

      expect(provider.isAuthenticated, isFalse);
      expect(provider.user, isNull);
    });
  });
}
