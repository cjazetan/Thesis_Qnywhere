// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qnywhere/model/business.dart';
import 'package:qnywhere/owner/ownerPage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class ShowBusinessQRCode extends StatefulWidget {
  const ShowBusinessQRCode({Key? key}) : super(key: key);

  @override
  State<ShowBusinessQRCode> createState() => _ShowBusinessQRCodeState();
}

class _ShowBusinessQRCodeState extends State<ShowBusinessQRCode> {
  final User user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xff294243),
          title: const Text("Business QR Code",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => OwnerPage(
                          ownerId: user.uid,
                          indexNo: 0,
                        )));
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ))),
      body: SafeArea(
        child: StreamBuilder<List<Business>>(
            stream: readBusiness(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something Went Wrong');
              } else if (snapshot.hasData) {
                final business = snapshot.data!;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.75,
                      decoration: BoxDecoration(
                          color: const Color(0xffD3D3D3),
                          borderRadius: BorderRadius.circular(25)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Powered by:  ",
                                style: TextStyle(
                                    color: Color(0xff294243), fontSize: 22),
                              ),
                              GradientText(
                                'Qnywhere',
                                style: const TextStyle(
                                    fontSize: 26.0,
                                    fontWeight: FontWeight.bold),
                                colors: const [
                                  Color(0xff398E7F),
                                  Color(0xff294243)
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              business.first.businessName,
                              style: const TextStyle(
                                  color: Color(0xff294243),
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 240,
                              child: Center(
                                child: QrImage(
                                  data: business.first.businessId,
                                  version: QrVersions.auto,
                                ),
                              )),
                          const SizedBox(height: 10),
                          const Center(
                            child: Text(
                              "Scan QR Code at the location\n to self-check in",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xff294243),
                                  fontSize: 22,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          const SizedBox(height: 35),
                          const Center(
                            child: Text(
                              "Thank you for visiting!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xff294243),
                                  fontSize: 22,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: 160,
                      height: 50,
                      decoration: const BoxDecoration(
                          color: Color(0xff294243),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: const Center(
                        child: Text('Download',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white)),
                      ),
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

  Stream<List<Business>> readBusiness() {
    return FirebaseFirestore.instance
        .collection('Business Accounts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['ownerId'].toString().contains(user.uid))
            .map((doc) => Business.fromJson(doc.data()))
            .toList());
  }
}
