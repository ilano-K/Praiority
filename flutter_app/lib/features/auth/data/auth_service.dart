import 'package:flutter_app/core/consants/auth_constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // supabase client
  final SupabaseClient _supabase = Supabase.instance.client;

  // Note: Ensure this is the "Web Client ID" from Google Cloud Console
  static const String _webClientId = AuthConstants.webClientId;

  // ✅ FIX 1: Use the Singleton Instance
  // The constructor GoogleSignIn() was removed in your version. You must use .instance
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Helper to ensure we only initialize once
  bool _isGoogleInitialized = false;

  /// ✅ FIX 2: Configuration Logic
  /// Since we can't pass config to the constructor, we use the initialize method.
  Future<void> _ensureGoogleInitialized() async {
    if (_isGoogleInitialized) return;

    try {
      await _googleSignIn.initialize(
        serverClientId: _webClientId,
        // Note: 'scopes' are not available in initialize() in this version.
        // You will request calendar permissions later using requestScopes() if needed.
      );
      _isGoogleInitialized = true;
    } catch (e) {
      // If it throws, it likely means it was already initialized elsewhere.
      // We catch it so the app doesn't crash.
      print("[AuthService] Warning: GoogleSignIn init check: $e");
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
      // handle errors
      rethrow;
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
      // handle errors
      rethrow;
    }
  }

  Future<AuthResponse> signInWithGoogle() async {
    try {
      // ✅ FIX 3: Initialize before signing in
      await _ensureGoogleInitialized();

      // trigger login pop up
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) throw 'No Id Token Found. Check Web Client ID.';

      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: null,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw 'Login canceled';
      }
      rethrow;
    } catch (e) {
      print("[DEBUG]: 1. AuthService - SIGN IN FAILED WITH ERROR: $e");
      rethrow;
    }
  }

  //sign out
  Future<void> signOut() async {
    print("[DEBUG]: 1. AuthService - Starting Google SignOut");
    try {
      await _googleSignIn.signOut();
      print("[DEBUG]: 2. AuthService - Google SignOut DONE");
    } catch (e) {
      print("[DEBUG]: 2. AuthService - Google SignOut FAILED: $e");
    }

    print("[DEBUG]: 3. AuthService - Starting Supabase SignOut");
    await _supabase.auth.signOut();
    print("[DEBUG]: 4. AuthService - Supabase SignOut DONE");
  }

  User? get currentUser => _supabase.auth.currentUser;
  String? get accessToken => _supabase.auth.currentSession?.accessToken;
}
