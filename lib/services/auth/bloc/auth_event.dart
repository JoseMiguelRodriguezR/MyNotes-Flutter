import 'package:flutter/foundation.dart' show immutable;

/*Aquí se definen los EVENTOS que se le pueden pasar al 
 AuthBloc. 3 posibles eventos ("inputs" al BLOC).*/ 

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

// verify_email_view enviará este EVENTO a nuestro BLOC
class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

// El evento de LogIn debe llevar consigo toda la info. necesaria
// para que el BLOC puede loggear al usuario.
class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogIn(this.email, this.password);
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  const AuthEventRegister(this.email, this.password);
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

class AuthEventForgotPassword extends AuthEvent {
  final String? email;
  const AuthEventForgotPassword({this.email});
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}