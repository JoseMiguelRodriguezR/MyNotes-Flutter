import 'package:firstapp/constants/routes.dart';
import 'package:firstapp/helpers/loading/loading_screen.dart';
import 'package:firstapp/services/auth/bloc/auth_bloc.dart';
import 'package:firstapp/services/auth/bloc/auth_event.dart';
import 'package:firstapp/services/auth/bloc/auth_state.dart';
import 'package:firstapp/services/auth/firebase_auth_provider.dart';
import 'package:firstapp/views/forgot_password_view.dart';
import 'package:firstapp/views/login_view.dart';
import 'package:firstapp/views/notes/create_update_note_view.dart';
import 'package:firstapp/views/notes/notes_view.dart';
import 'package:firstapp/views/register_view.dart';
import 'package:firstapp/views/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  //Antes de correr la App debemos asegurarnos que Firebase (BD) ha ejecutado sus procesos.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    context.read<AuthBloc>()              // context contiene nuestro AuthBloc
      .add(const AuthEventInitialize());  // la manera de comunicarnos con un BLOC es mediante su función "add".
                                    
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading){
          LoadingScreen().show(
            context: context, 
            text: state.loadingText ?? 'Please wait a moment',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn){
          return const NotesView();
        } else if (state is AuthStateNeedsVerification){
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut){
          return const LoginView();
        } else if (state is AuthStateForgotPassword){
          return const ForgotPasswordView();
        } else if (state is AuthStateRegistering){
          return const RegisterView();
        }else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );

  }
}
