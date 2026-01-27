import 'dart:async';
import 'package:flutter_app/features/auth/data/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>((){
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  @override  
  FutureOr<void> build(){
    //
  } 
  Future<void> signUp({required String username, required String email, required String password}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async{
        final authService = ref.read(authServiceProvider);
        await authService.signUp(username, email, password);
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    state = AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      await authService.signIn(email, password);  
    });
  }

  Future<void> signOut() async {
    state = AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
    });
  }
}