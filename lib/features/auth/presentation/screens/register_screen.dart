import 'package:flutter/material.dart';
import 'package:xstackapp/features/auth/presentation/screens/auth_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthScreen(mode: AuthMode.register);
  }
}
