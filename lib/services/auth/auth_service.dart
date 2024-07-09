import 'package:firstapp/services/auth/auth_provider.dart';
import 'package:firstapp/services/auth/auth_user.dart';
import 'package:firstapp/services/auth/firebase_auth_provider.dart';

// Esta clase implementa el servicio de "provider (firebase_auth_provider.dart)".
// Se hace así porque pueden existir más servicios a implementar,
// cosa que es tarea de auth_service.dart

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider(),);

  @override
  Future<AuthUser> createUser({required String email, required String password,}) {
    return provider.createUser(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({required String email, required String password,}) {
    return provider.logIn(email: email, password: password);
  }

  @override
  Future<void> logOut() => provider.logOut();
  

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
  

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<void> sendPasswordReset({required String toEmail}) => 
    provider.sendPasswordReset(toEmail: toEmail);
}