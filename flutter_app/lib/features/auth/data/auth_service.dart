import 'package:flutter_app/core/consants/auth_constants.dart';
import 'package:flutter_app/core/errors/app_exceptions.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // supabase client
  final SupabaseClient _supabase = Supabase.instance.client;

  // Note: Ensure this is the "Web Client ID" from Google Cloud Console
  static const String _webClientId = AuthConstants.webClientId;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Helper to ensure we only initialize once
  bool _isGoogleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_isGoogleInitialized) return;

    try {
      await _googleSignIn.initialize(serverClientId: _webClientId);
      _isGoogleInitialized = true;
    } catch (e) {
      _isGoogleInitialized = true;
    }
  }

  // account creation
  Future<AuthResponse> signUp(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'praiority.scheduler://login-callback',
        data: {"username": username},
      );
      return response;
    } catch (e) {
      throw parseError(e);
    }
  }

  // sign in
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw parseError(e);
    }
  }

  Future<AuthResponse> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      // trigger login pop up
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken!,
        accessToken: null,
      );
    } catch (e) {
      throw parseError(e);
    }
  }

  //sign out
  Future<void> signOut() async {
    try {
      // Try to sign out of Google (silently ignore errors)
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      // Sign out of Supabase
      await _supabase.auth.signOut();
    } catch (e) {
      throw parseError(e);
    }
  }

  // forget password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: AuthConstants.callbackUrl,
      );
    } catch (e) {
      throw parseError(e);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      print(e);
      throw parseError(e);
    }
  }

  User? get currentUser => _supabase.auth.currentUser;
  String? get accessToken => _supabase.auth.currentSession?.accessToken;
}
