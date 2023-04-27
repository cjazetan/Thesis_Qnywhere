// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:qnywhere/auth/login.dart';
import 'package:qnywhere/auth/register.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  @override
  Widget build(BuildContext context) => isLogin
      ? LoginPage(onClickedSignUp: toggle)
      : RegisterPage(
          onClickedSignIn: toggle,
          onClickedSignUp: toggle,
        );

  void toggle() => setState(() => isLogin = !isLogin);
}
