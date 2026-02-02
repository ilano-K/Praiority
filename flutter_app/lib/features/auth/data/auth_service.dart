import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // supabase client
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _webClientId = "863361017196-70lclvjrohu7mtio0kpb9d4oblrjusd5.apps.googleusercontent.com";

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId,
  );

  // account creation 
  Future<AuthResponse> signUp(String username, String email, String password) async {
    try{
      final response = await _supabase.auth.signUp(

        email: email,
        password: password,
        emailRedirectTo: 'praiority.scheduler://login-callback',
        data: {
          "username": username,
        }
      );
      return response;
    }catch (e){
      // handle errors 
      rethrow;
    }
  }

  // sign in 
  Future<AuthResponse> signIn(String email, String password) async {
    try{
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password
      );
      return response;
    }catch (e){
       // handle errors 
      rethrow;
    }
  }

  Future<AuthResponse> signInWithGoogle() async {
    try{
      // trigger login pop up
      final googleUser = await _googleSignIn.signIn();

      if(googleUser == null){
        throw 'Login canceled';
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if(idToken == null)throw  'No Id Token Found';

      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google, 
        idToken: idToken, 
        accessToken: accessToken
      ); 
    }catch (e){
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