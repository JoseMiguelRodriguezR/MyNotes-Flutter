import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable  //esta clase y sus clases hijas no podrán tener atributos mutables.
class AuthUser {
  // at this point the user exists in FireBase but no in our BD which controls all functionality. 
  final String id;
  final String email;
  final bool isEmailVerified;
  const AuthUser( {
    required this.id,
    required this.email, 
    required this.isEmailVerified,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
      id: user.uid,
      email: user.email!, 
      isEmailVerified: user.emailVerified
    );
}

