
import 'package:equatable/equatable.dart';
import 'package:firstapp/services/auth/auth_user.dart';
import 'package:flutter/foundation.dart' show immutable;


/*Aquí se definen los ESTADOS del BLOC respecto al proceso de 
 autenticación del usuario. 5 posibles estados ("outputs" del BLOC).*/ 

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({required this.isLoading, this.loadingText= 'Please wait a moment',});
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required bool isLoading}) : super(isLoading: isLoading);
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({required this.exception, required bool isLoading}) : 
  super(isLoading: isLoading);
}

class AuthStateForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail;
  const AuthStateForgotPassword({
    required this.exception, 
    required this.hasSentEmail,
    required bool isLoading,
    }) : super(isLoading: isLoading);
}


// Obtenemos el usuario logged desde el ESTADO ACTUAL del BLOC.
// De este modo es como separamos UI de AuthService poniendo un BLOC en medio.
class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({required this.user, required bool isLoading}) : 
  super(isLoading: isLoading);
}

// si el user existe pero no se verificó.
class AuthStateNeedsVerification extends AuthState {   
  const AuthStateNeedsVerification({required bool isLoading}) : super(isLoading: isLoading);
}


/* POSOBLES ESTADOS DE LOGGEDOUT
 - exception=null isLoading=false
 - exception=null isLoading=true
 - exception=notNull isLoading=false
*/
class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception; //Le pasamos una excepción condicional por si sucede.
  const AuthStateLoggedOut({ 
    required this.exception, 
    required bool isLoading, 
    String? loadingText
  }) : super(isLoading: isLoading, loadingText: loadingText);

  // Usamos el paquete "equatable" para distinguir entre ESTADOS. (los comentados arriba).
  @override
  List<Object?> get props => [exception, isLoading];
}
