
import 'package:flutter_app/features/auth/data/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authServiceProvider = Provider<AuthService>((ref){
  return AuthService();
});

final authStateProvider = StreamProvider<AuthState>((ref){
  return Supabase.instance.client.auth.onAuthStateChange;
});