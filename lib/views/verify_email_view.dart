import 'package:firstapp/constants/routes.dart';
import 'package:firstapp/services/auth/auth_service.dart';
import 'package:firstapp/services/auth/bloc/auth_bloc.dart';
import 'package:firstapp/services/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({ Key? key }) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify email'),
      ),
      body: Column(
        children:[
          const Text("We've sent you an email verification. Please open it to verify your account.\n"),
          const Text("If you haven't received a verification email, press the button below."),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
            }, 
            child: const Text('Send email verification'),
          ),
          TextButton(
            onPressed: () {
                context.read<AuthBloc>().add(const AuthEventLogOut());
            }, 
            child: const Text('Restart')
          )
        ],
      ),
    );
  }
}