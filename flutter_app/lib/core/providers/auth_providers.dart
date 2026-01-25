import 'package:flutter_riverpod/flutter_riverpod.dart';

// This acts as a placeholder for your future Auth system.
// For now, it just gives every feature a consistent "local_user" ID.
final currentUserIdProvider = Provider<String?>((ref) {
  return "dev_user_phil_2026"; 
}); 