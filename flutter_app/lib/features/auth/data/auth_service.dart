import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // supabase client
  final SupabaseClient _supabase = Supabase.instance.client;

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

  //sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
  String? get accessToken => _supabase.auth.currentSession?.accessToken;
}