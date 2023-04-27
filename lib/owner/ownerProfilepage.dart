// ignore_for_file: file_namess, file_names, avoid_print, use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qnywhere/model/owner.dart';
import 'package:qnywhere/onboarding.dart';
import 'package:qnywhere/owner/editBusiness.dart';
import 'package:qnywhere/owner/editOwner.dart';
import 'package:qnywhere/owner/ownerPage.dart';
import 'package:qnywhere/owner/ownerStatistics.dart';
import 'package:qnywhere/owner/showQRCode.dart';
import 'package:qnywhere/utilities/profileMenuButton.dart';

class OwnerProfilePage extends StatefulWidget {
  const OwnerProfilePage({Key? key}) : super(key: key);

  @override
  State<OwnerProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<OwnerProfilePage> {
  final User user = FirebaseAuth.instance.currentUser!;

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
        child: StreamBuilder<List<Owner>>(
            stream: readOwner(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something Went Wrong');
              } else if (snapshot.hasData) {
                final owner = snapshot.data!;
                print(owner.length);
                return Column(
                  children: [
                    Stack(
                      children: [
                        Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.33,
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                  color: Color(0xff398E7F),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(40.0),
                                    bottomRight: Radius.circular(40.0),
                                  )),
                            ),
                            const SizedBox(height: 60),
                            ProfileMenuButton(
                              icon: Icons.bar_chart,
                              text: "Statistics",
                              press: (() {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const BusinessStatistics()));
                              }),
                            ),
                            ProfileMenuButton(
                              icon: Icons.settings,
                              text: "Edit Business Profile",
                              press: (() {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const EditBusiness()));
                              }),
                            ),
                            ProfileMenuButton(
                              icon: Icons.qr_code_2,
                              text: "Business QR Code",
                              press: (() {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ShowBusinessQRCode()));
                              }),
                            ),
                            ProfileMenuButton(
                              icon: Icons.person,
                              text: "About Me",
                              press: (() {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const EditOwner()));
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
                          top: 125,
                          left: 25,
                          child: Container(
                            height: 170,
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
                                        '${owner.first.accountFirstName} ${owner.first.accountLastName}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    const SizedBox(height: 10),
                                    Text(owner.first.accountEmail,
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
                          top: 70,
                          left: 35,
                          child: Container(
                            height: 200,
                            width: 160,
                            decoration: BoxDecoration(
                                color: const Color(0xffD9D9D9),
                                borderRadius: BorderRadius.circular(30)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: (owner.first.imageUrl == "")
                                  ? const Center(
                                      child: Icon(
                                      Icons.person,
                                      size: 30,
                                    ))
                                  : Image.network(owner.first.imageUrl,
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

  Stream<List<Owner>> readOwner() {
    return FirebaseFirestore.instance
        .collection('Owner Accounts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['accountID'].toString().contains(user.uid))
            .map((doc) => Owner.fromJson(doc.data()))
            .toList());
  }
}
