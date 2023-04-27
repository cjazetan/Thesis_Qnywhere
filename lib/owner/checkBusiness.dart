// ignore_for_file: file_names, avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qnywhere/model/business.dart';
import 'package:qnywhere/owner/addBusiness.dart';
import 'package:qnywhere/owner/ownerPage.dart';

class CheckBusiness extends StatefulWidget {
  final String ownerID;
  const CheckBusiness({Key? key, required this.ownerID}) : super(key: key);

  @override
  State<CheckBusiness> createState() => _CheckBusinessState();
}

class _CheckBusinessState extends State<CheckBusiness> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Business>>(
            stream: readBusiness(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return Text('Something Went Wrong ${snapshot.error}');
              } else if (snapshot.hasData) {
                final business = snapshot.data!;
                print(business.isNotEmpty);

                if (business.isNotEmpty) {
                  return OwnerPage(
                    ownerId: widget.ownerID,
                    indexNo: 0,
                  );
                } else {
                  return AddBusiness(ownerID: widget.ownerID);
                }
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
                element['ownerId'].toString().contains(widget.ownerID))
            .map((doc) => Business.fromJson(doc.data()))
            .toList());
  }
}
