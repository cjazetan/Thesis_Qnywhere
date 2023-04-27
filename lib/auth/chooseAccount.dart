// ignore_for_file: file_names, use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qnywhere/auth/readAccount.dart';
import 'package:qnywhere/model/user.dart';
import 'package:qnywhere/user/userPage.dart';

class ChooseAccountPage extends StatefulWidget {
  final VoidCallback onClickedSignIn;
  final VoidCallback onClickedSignUp;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String pass;
  const ChooseAccountPage({
    Key? key,
    required this.onClickedSignIn,
    required this.onClickedSignUp,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.pass,
  }) : super(key: key);

  @override
  State<ChooseAccountPage> createState() => _ChooseAccountPageState();
}

class _ChooseAccountPageState extends State<ChooseAccountPage> {
  bool isLoading = false;
  final User user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff398E7F),
            Color(0xff294243),
          ],
        )),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Image.asset(
                'assets/images/circle.png',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 385, left: 100),
              child: Image.asset(
                'assets/images/circle1.png',
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Center(
                  child: Text(
                    "Pick your Choice",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    List<Recents> recents = const [];
                    final uploadTime = DateTime.now();
                    Timestamp myTimeStamp = Timestamp.fromDate(uploadTime);
                    final docOwner = FirebaseFirestore.instance
                        .collection('User Accounts')
                        .doc(user.uid);

                    final data = {
                      'accountID': user.uid,
                      'accountEmail': widget.email,
                      'accountFirstName': widget.firstName,
                      'accountLastName': widget.lastName,
                      'accountPhoneNumber': widget.phone,
                      'imageUrl': "",
                      'queueBusiness': "",
                      'inQueue': false,
                      'dateCreated': myTimeStamp,
                      'recentQueued': recents
                    };
                    docOwner.set(data);
                    await Future.delayed(const Duration(seconds: 3));

                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => UserPage(
                              userId: user.uid,
                              indexNo: 1,
                            )));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 35),
                    height: MediaQuery.of(context).size.height * 0.27,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(153, 240, 240, 240),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/user.png'),
                        const SizedBox(width: 25),
                        const Text(
                          "User",
                          style: TextStyle(
                              color: Color(0xFF294243),
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });

                    final uploadTime = DateTime.now();
                    Timestamp myTimeStamp = Timestamp.fromDate(uploadTime);
                    final docOwner = FirebaseFirestore.instance
                        .collection('Owner Accounts')
                        .doc(user.uid);

                    final data = {
                      'accountID': user.uid,
                      'accountEmail': widget.email,
                      'accountFirstName': widget.firstName,
                      'accountLastName': widget.lastName,
                      'accountPhoneNumber': widget.phone,
                      'haveBusiness': false,
                      'imageUrl': "",
                      'dateCreated': myTimeStamp,
                    };
                    docOwner.set(data);
                    await Future.delayed(const Duration(seconds: 3));

                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const ReadAccount()));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 35),
                    height: MediaQuery.of(context).size.height * 0.27,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(153, 240, 240, 240),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/owner.png'),
                        const SizedBox(width: 25),
                        const Text(
                          "Owner",
                          style: TextStyle(
                              color: Color(0xFF294243),
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
