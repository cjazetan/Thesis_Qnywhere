// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:qnywhere/auth/readAccount.dart';
import 'package:qnywhere/components/round_container.dart';
import 'package:qnywhere/components/round_field.dart';
import 'package:qnywhere/components/utils.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onClickedSignUp;
  const LoginPage({Key? key, required this.onClickedSignUp}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageScreenState();
}

class _LoginPageScreenState extends State<LoginPage> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  bool obscuredText = true;
  bool isLoading = false;
  Color obscuredIconColor = const Color.fromRGBO(141, 141, 141, 100);

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  Future signIn() async {
    bool hasError = false;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: username.text.trim(),
        password: password.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (e.message!.isNotEmpty) {
        hasError = true;
        print(e.message);
        print(hasError);
      }
      if (e.message == "Given String is empty or null") {
        Utils.errorSnackBar(
            Icons.error, "Please input your username and password");
      } else {
        Utils.errorSnackBar(Icons.error, e.message.toString());
      }
    }
    if (hasError == false) {
      Future.delayed(const Duration(seconds: 5), () {
        isLoading = false;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ReadAccount()));
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff398E7F),
        foregroundColor: Colors.white,
        actions: [
          GestureDetector(
              onTap: (() {
                widget.onClickedSignUp();
              }),
              child: const Center(
                  child: Padding(
                padding: EdgeInsets.only(right: 20),
                child: Text(
                  'Register',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              )))
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xff398E7F)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.30,
                width: MediaQuery.of(context).size.width,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(height: 25),
                      Center(
                        child: Text(
                          "Qnywhere.",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 45,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 40),
                      Padding(
                        padding: EdgeInsets.only(left: 50),
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 50),
                        child: Text(
                          "Welcome back! We've missed you",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ]),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.70,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 30),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: RoundedInput(
                          icon: Icons.mail,
                          hint: 'Email',
                          controller: username,
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: passwordField(),
                      ),
                    ),
                    GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 50, top: 10),
                          child: Text(
                            'FORGOT PASSWORD?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        onTap: () {}),
                    const SizedBox(height: 30),
                    Center(child: loginButton(size)),
                    const SizedBox(height: 30),
                    Center(
                      child: RichText(
                          text: TextSpan(
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                              text: 'Don\'t have an account?  ',
                              children: [
                            TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = widget.onClickedSignUp,
                                text: 'Sign Up',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xff294243),
                                ))
                          ])),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  InputContainer passwordField() {
    Size size = MediaQuery.of(context).size;
    return InputContainer(
        size: size * 0.8,
        child: TextField(
          style: const TextStyle(color: Color.fromRGBO(141, 141, 141, 100)),
          controller: password,
          cursorColor: const Color.fromRGBO(141, 141, 141, 100),
          obscureText: obscuredText,
          decoration: InputDecoration(
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.lock,
                  color: Color.fromRGBO(141, 141, 141, 100)),
              hintText: 'Password',
              hintStyle:
                  const TextStyle(color: Color.fromRGBO(141, 141, 141, 100)),
              border: InputBorder.none,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    if (obscuredText == true) {
                      obscuredText = !obscuredText;
                      obscuredIconColor = Colors.black;
                    } else {
                      obscuredText = !obscuredText;
                      obscuredIconColor =
                          const Color.fromRGBO(141, 141, 141, 100);
                    }
                  });
                },
                icon: (obscuredText != true)
                    ? Icon(
                        Icons.visibility,
                        color: obscuredIconColor,
                      )
                    : Icon(
                        Icons.visibility_off,
                        color: obscuredIconColor,
                      ),
              )),
        ));
  }

  InkWell loginButton(Size size) {
    return InkWell(
      onTap: (() {
        setState(() {
          isLoading = true;
        });

        signIn();
      }),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: size.width * 0.7,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color(0xff294243),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        child: (isLoading == true)
            ? const CircularProgressIndicator()
            : const Text(
                'LOGIN',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
