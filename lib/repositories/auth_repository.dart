import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import '../core/config/supabase_config.dart';
import '../models/user_profile.dart';

class AuthRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<UserProfile?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Starting sign up for: $email');

      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      print('✅ Auth user created: ${user?.id}');

      if (user != null) {
        try {
          // Create user profile in the users table
          print('📝 Creating user profile in database...');

          final profileData = {
            'id': user.id,
            'email': email,
            'created_at': DateTime.now().toIso8601String(),
          };

          print('Profile data: $profileData');

          // Insert and return the created profile
          final profileResponse =
              await _client.from('users').insert(profileData).select().single();

          print('✅ User profile created: $profileResponse');

          return UserProfile.fromJson(profileResponse);
        } catch (profileError) {
          print('❌ Failed to create user profile: $profileError');

          // If profile creation fails, try to get existing profile
          // (in case it was created by a database trigger)
          try {
            print('🔄 Attempting to fetch existing profile...');
            return await getUserProfile(user.id);
          } catch (e) {
            print('❌ Failed to fetch profile: $e');
            throw Exception(
                'Failed to create user profile: ${profileError.toString()}');
          }
        }
      }

      return null;
    } catch (e) {
      print('❌ Sign up failed: $e');
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  Future<UserProfile?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting sign in for: $email');

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        print('✅ Auth successful: ${user.id}');

        try {
          // Try to get existing profile
          print('🔄 Fetching user profile...');
          final profile = await getUserProfile(user.id);
          if (profile != null) {
            print('✅ Profile found: ${profile.id}');
            return profile;
          }
          throw Exception('Profile is null');
        } catch (profileError) {
          // Profile doesn't exist - create it now
          print(
              '⚠️ Profile not found, creating new profile for existing user...');

          try {
            final profileData = {
              'id': user.id,
              'email': email,
              'created_at': DateTime.now().toIso8601String(),
            };

            print('📝 Creating profile: $profileData');

            final profileResponse = await _client
                .from('users')
                .insert(profileData)
                .select()
                .single();

            print('✅ Profile created on login: $profileResponse');
            return UserProfile.fromJson(profileResponse);
          } catch (createError) {
            print('❌ Failed to create profile on login: $createError');

            // One more attempt to fetch (in case of race condition)
            try {
              await Future.delayed(const Duration(milliseconds: 300));
              return await getUserProfile(user.id);
            } catch (finalError) {
              print('❌ All attempts to get/create profile failed');
              throw Exception(
                  'Failed to get or create user profile: ${createError.toString()}');
            }
          }
        }
      }

      return null;
    } catch (e) {
      print('❌ Sign in failed: $e');
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response =
          await _client.from('users').select().eq('id', userId).single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    try {
      final response = await _client
          .from('users')
          .update(profile.toJson())
          .eq('id', profile.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  /// Sign in with Google
  Future<UserProfile?> signInWithGoogle() async {
    try {
      print('🔐 Starting Google Sign-In...');

      // Initialize Google Sign In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: const String.fromEnvironment(
          'GOOGLE_SERVER_CLIENT_ID',
          defaultValue: '', // Will be configured per platform
        ),
      );

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('⚠️ Google Sign-In cancelled by user');
        return null;
      }

      print('✅ Google user: ${googleUser.email}');

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('No ID Token found');
      }

      print('🔑 Got Google tokens, signing in to Supabase...');

      // Sign in to Supabase with Google credentials
      final AuthResponse response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user != null) {
        print('✅ Supabase auth successful: ${user.id}');

        // Try to get or create user profile
        try {
          final profile = await getUserProfile(user.id);
          if (profile != null) {
            print('✅ Profile found: ${profile.id}');
            return profile;
          }
        } catch (profileError) {
          print('⚠️ Profile not found, creating new profile...');
        }

        // Create profile if it doesn't exist
        try {
          final profileData = {
            'id': user.id,
            'email': user.email ?? googleUser.email,
            'name': googleUser.displayName,
            'created_at': DateTime.now().toIso8601String(),
          };

          print('📝 Creating profile: $profileData');

          final profileResponse = await _client
              .from('users')
              .insert(profileData)
              .select()
              .single();

          print('✅ Profile created: $profileResponse');
          return UserProfile.fromJson(profileResponse);
        } catch (createError) {
          print('❌ Failed to create profile: $createError');
          // Try one more time to fetch in case of race condition
          await Future.delayed(const Duration(milliseconds: 300));
          return await getUserProfile(user.id);
        }
      }

      return null;
    } catch (e) {
      print('❌ Google Sign-In failed: $e');
      throw Exception('Google Sign-In failed: ${e.toString()}');
    }
  }

  /// Sign in with Apple (iOS only)
  Future<UserProfile?> signInWithApple() async {
    try {
      print('🔐 Starting Apple Sign-In...');

      // Generate random nonce
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      // Request Apple ID credential
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('No identity token found');
      }

      print('🔑 Got Apple token, signing in to Supabase...');

      // Sign in to Supabase with Apple credentials
      final AuthResponse response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      final user = response.user;
      if (user != null) {
        print('✅ Supabase auth successful: ${user.id}');

        // Try to get or create user profile
        try {
          final profile = await getUserProfile(user.id);
          if (profile != null) {
            print('✅ Profile found: ${profile.id}');
            return profile;
          }
        } catch (profileError) {
          print('⚠️ Profile not found, creating new profile...');
        }

        // Create profile if it doesn't exist
        try {
          final name = credential.givenName != null && credential.familyName != null
              ? '${credential.givenName} ${credential.familyName}'
              : null;

          final profileData = {
            'id': user.id,
            'email': user.email ?? credential.email,
            'name': name,
            'created_at': DateTime.now().toIso8601String(),
          };

          print('📝 Creating profile: $profileData');

          final profileResponse = await _client
              .from('users')
              .insert(profileData)
              .select()
              .single();

          print('✅ Profile created: $profileResponse');
          return UserProfile.fromJson(profileResponse);
        } catch (createError) {
          print('❌ Failed to create profile: $createError');
          await Future.delayed(const Duration(milliseconds: 300));
          return await getUserProfile(user.id);
        }
      }

      return null;
    } catch (e) {
      print('❌ Apple Sign-In failed: $e');
      throw Exception('Apple Sign-In failed: ${e.toString()}');
    }
  }

  /// Generate random nonce for Apple Sign-In
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }
}
