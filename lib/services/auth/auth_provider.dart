import 'package:firstapp/services/auth/auth_user.dart';

// este clase abstracta sirve pata las funcionalidades de FireBase.
// (registrarse por gmail, facebook, email+contra, etc...)

abstract class AuthProvider {

  Future<void> initialize();

  AuthUser? get currentUser;
  
  Future<AuthUser> logIn({required String email, required String password,});
  
  Future<AuthUser> createUser({required String email, required String password,});
  
  Future<void> logOut();
  
  Future<void> sendEmailVerification();

  Future<void> sendPasswordReset({required String toEmail});
}