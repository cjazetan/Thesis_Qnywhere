// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:qnywhere/auth/chooseAccount.dart';
import 'package:qnywhere/components/square_field.dart';
import 'package:qnywhere/components/utils.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onClickedSignIn;
  final VoidCallback onClickedSignUp;
  const RegisterPage(
      {Key? key, required this.onClickedSignIn, required this.onClickedSignUp})
      : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController first = TextEditingController();
  TextEditingController last = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController pass = TextEditingController();
  bool hasError = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              widget.onClickedSignIn();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 45),
              child: Text(
                "Create an Account",
                style: TextStyle(
                    color: Color(0xFF294243),
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SquareInput(
                  icon: Icons.person,
                  hint: 'First Name',
                  controller: first,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SquareInput(
                  icon: Icons.person,
                  hint: 'Last Name',
                  controller: last,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SquareInput(
                  icon: Icons.email,
                  hint: 'Email',
                  controller: email,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SquareInput(
                  icon: Icons.phone,
                  hint: 'Phone Number',
                  controller: phone,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: (isLoading)
                    ? const CircularProgressIndicator()
                    : SquareInput(
                        icon: Icons.lock,
                        hint: 'Password',
                        controller: pass,
                      ),
              ),
            ),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                "By signing up, you agree to our Terms and\n Condition and Privacy Policy",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF294243),
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            Center(child: registerButton(size)),
            const SizedBox(height: 30),
            Center(
              child: RichText(
                  text: TextSpan(
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                      text: 'Already have an account?  ',
                      children: [
                    TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = widget.onClickedSignIn,
                        text: 'Sign In',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xff294243),
                        ))
                  ])),
            ),
          ],
        ),
      )),
    );
  }

  InkWell registerButton(Size size) {
    return InkWell(
      onTap: (() async {
        if (first.text.isEmpty ||
            last.text.isEmpty ||
            email.text.isEmpty ||
            phone.text.isEmpty ||
            pass.text.isEmpty) {
          Utils.errorSnackBar(
              Icons.error, "Please complete all the requirements");
        } else {
          signUp();
          if (hasError == true) {
            setState(() {
              first.clear();
              last.clear();
              email.clear();
              phone.clear();
              pass.clear();
            });
          } else {
            await Future.delayed(const Duration(seconds: 3));
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChooseAccountPage(
                      onClickedSignIn: widget.onClickedSignIn,
                      onClickedSignUp: widget.onClickedSignUp,
                      firstName: first.text,
                      lastName: last.text,
                      email: email.text,
                      phone: phone.text,
                      pass: pass.text,
                    )));
          }
        }
      }),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: size.width * 0.7,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color.fromARGB(255, 0, 33, 59),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        child: const Text(
          'Sign Up',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future signUp() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: pass.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (e.message!.isNotEmpty) {
        hasError = true;
      }
      if (e.message == "Given String is empty or null") {
        Utils.errorSnackBar(
            Icons.error, "Please input your username and password");
      } else {
        Utils.errorSnackBar(Icons.error, e.message.toString());
      }
    }
  }
}
