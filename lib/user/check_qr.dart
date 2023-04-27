// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qnywhere/components/utils.dart';
import 'package:qnywhere/model/business.dart';
import 'package:qnywhere/user/qr_scanner.dart';
import 'package:qnywhere/user/userPage.dart';
import 'package:qnywhere/user/viewBusinessPage.dart';

class CheckQrPage extends StatefulWidget {
  final String businessID;
  const CheckQrPage({Key? key, required this.businessID}) : super(key: key);

  @override
  State<CheckQrPage> createState() => _CheckQrPageState();
}

class _CheckQrPageState extends State<CheckQrPage> {
  final User users = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
              Color(0xff398E7F),
              Color(0xff294243),
            ]))),
        elevation: 0,
      ),
      body: StreamBuilder<List<Business>>(
          stream: readInfoPage(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something Went Wrong');
            } else if (snapshot.hasData) {
              final business = snapshot.data!;
              if (business.isEmpty) {
                print("error qr code");
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Invalid QR Code",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Color(0xff294243)),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "The QR Code",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 22,
                          color: Colors.black),
                    ),
                    Text(
                      "${widget.businessID} is not a valid\n authentication token",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 22,
                          color: Colors.black),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        returnHome(size),
                        tryAgain(size),
                      ],
                    ),
                  ],
                );
              } else {
                print("success qr code");
                return ViewBusinessPage(
                  businessId: business.first.businessId,
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  InkWell returnHome(Size size) {
    return InkWell(
      onTap: (() {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => UserPage(indexNo: 1, userId: users.uid)));
      }),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: size.width * 0.45,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color.fromARGB(255, 0, 33, 59),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        child: const Text(
          'Return',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  InkWell tryAgain(Size size) {
    return InkWell(
      onTap: (() {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ScanQrCodePage()));
      }),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: size.width * 0.45,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color.fromARGB(255, 0, 33, 59),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        child: const Text(
          'Try Again',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Stream<List<Business>> readInfoPage() {
    return FirebaseFirestore.instance
        .collection('Business Accounts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['businessId'].toString().contains(widget.businessID))
            .map((doc) => Business.fromJson(doc.data()))
            .toList());
  }
}
