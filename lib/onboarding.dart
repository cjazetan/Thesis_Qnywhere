import 'package:flutter/material.dart';
import 'package:qnywhere/auth/authPage.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              Color(0xff39848E),
              Color(0xff294243),
            ])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Image.asset('assets/images/hero.png'),
            ),
            const SizedBox(height: 10),
            const Text(
              "Qnywhere.",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const AuthPage()));
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(10),
                fixedSize: const Size(260, 60),
                textStyle:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                primary: Colors.white,
                onPrimary: const Color(0xff294243),
                elevation: 15,
                shadowColor: const Color.fromRGBO(41, 66, 67, 100),
              ),
              child: const Text("Get Started"),
            )
          ],
        ),
      ),
    );
  }
}
