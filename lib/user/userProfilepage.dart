// ignore_for_file: file_namess, file_names, avoid_print, use_build_context_synchronously, prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qnywhere/model/user.dart';
import 'package:qnywhere/onboarding.dart';
import 'package:qnywhere/user/editUser.dart';
import 'package:qnywhere/user/qr_scanner.dart';
import 'package:qnywhere/user/userPage.dart';
import 'package:qnywhere/utilities/profileMenuButton.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final User users = FirebaseAuth.instance.currentUser!;

  _signOut() async {
    await FirebaseAuth.instance.signOut();

    FirebaseAuth.instance.userChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Users>>(
            stream: readUser(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Something Went Wrong ${snapshot.error}');
              } else if (snapshot.hasData) {
                final user = snapshot.data!;
                print(user.length);
                return Column(
                  children: [
                    Stack(
                      children: [
                        Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.43,
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                  color: Color(0xff398E7F),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(40.0),
                                    bottomRight: Radius.circular(40.0),
                                  )),
                            ),
                            const SizedBox(height: 50),
                            ProfileMenuButton(
                              icon: Icons.person,
                              text: "About Me",
                              press: (() {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const EditUser()));
                              }),
                            ),
                            ProfileMenuButton(
                              icon: Icons.notifications,
                              text: "Notifications",
                              press: (() {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => UserPage(
                                            userId: users.uid, indexNo: 2)));
                              }),
                            ),
                            ProfileMenuButton(
                              icon: Icons.av_timer,
                              text: "Scan QR Code",
                              press: (() {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ScanQrCodePage()));
                              }),
                            ),
                            ProfileMenuButton(
                              icon: Icons.person,
                              text: "Log out",
                              press: _signOut,
                            ),
                          ],
                        ),
                        Positioned(
                          top: 150,
                          left: 25,
                          child: Container(
                            height: 200,
                            width: MediaQuery.of(context).size.width * 0.88,
                            decoration: const BoxDecoration(
                                color: Color(0xff294243),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const SizedBox(
                                  width: 150,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                        '${user.first.accountFirstName} ${user.first.accountLastName}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    const SizedBox(height: 10),
                                    Text(user.first.accountEmail,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.white)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 160,
                          left: 45,
                          child: Container(
                            height: 180,
                            width: 150,
                            decoration: BoxDecoration(
                                color: const Color(0xffD9D9D9),
                                borderRadius: BorderRadius.circular(30)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: (user.first.imageUrl == "")
                                  ? const Center(
                                      child: Icon(
                                      Icons.person,
                                      size: 30,
                                    ))
                                  : Image.network(user.first.imageUrl,
                                      height: 200,
                                      width: 160,
                                      fit: BoxFit.fill),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }

  Stream<List<Users>> readUser() {
    return FirebaseFirestore.instance
        .collection('User Accounts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['accountID'].toString().contains(users.uid))
            .map((doc) => Users.fromJson(doc.data()))
            .toList());
  }
}
