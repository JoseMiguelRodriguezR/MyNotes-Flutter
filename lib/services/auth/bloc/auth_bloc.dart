/*Aquí es donde unificamos los EVENTOS con los ESTADOS
 a partir del BLOC (lógica del AuthBloc).*/

import 'package:bloc/bloc.dart';
import 'package:firstapp/services/auth/auth_provider.dart';
import 'package:firstapp/services/auth/bloc/auth_event.dart';
import 'package:firstapp/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized(isLoading: true)){
    // inside the AuthBloc.
    // según el evento que reciba ...actuará de una forma concreta.

    // REGISTER
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(
        exception: null, 
        isLoading: false
        ));
    });

    // FORGOT PASSWORD
    on<AuthEventForgotPassword>((event, emit) async {
      // en este estado el user hace la petición de ForgotPassword.
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: false,
      )); 
      final email = event.email;
      if (email == null){
        return; //user just wants to go to forgot-password screen.
      }

      // user wants to actually send a forgot-password email.
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: true,
      ));

      bool didSendEmail;      // Estas 2 variables nos servirán para emitir
      Exception? exception;   //  el AuthState ForgotPassword.
      try {
        await provider.sendPasswordReset(toEmail: email);
        didSendEmail = true;
        exception = null; 
      } on Exception catch(e) {
        didSendEmail = false;
        exception = e;
      }

      emit(AuthStateForgotPassword(
        exception: exception,
        hasSentEmail: didSendEmail,
        isLoading: false,
      ));

    });

    // SEND EMAIL VERIFICATION
    on<AuthEventSendEmailVerification>((event, emit) async{
      await provider.sendEmailVerification();
      emit(state);
    });

    // REGISTER
    on<AuthEventRegister>((event,emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification(isLoading: false));
      } on Exception catch (e){
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    });

    // INITIALIZE
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user==null){
                      // ...default state. Loading screen.
        emit(
          const AuthStateLoggedOut(exception: null, isLoading: false));
      } else if (!user.isEmailVerified){
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });

    // LOG IN
    on<AuthEventLogIn>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
          exception: null, 
          isLoading: true, 
          loadingText: 'Please wait, logging in...'
        )
      ); // Loading screen
      final email = event.email;
      final password = event.password;
      try {

        final user = await provider.logIn(email: email, password: password);

        if (!user.isEmailVerified){
          emit(const AuthStateLoggedOut(exception: null, isLoading: false)); // Loading screen
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else{
          emit(const AuthStateLoggedOut(exception: null, isLoading: false)); // Loading screen
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        }
        
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    // LOG OUT
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
  }
}