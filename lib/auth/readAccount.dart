// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qnywhere/model/owner.dart';
import 'package:qnywhere/owner/checkBusiness.dart';
import 'package:qnywhere/user/userPage.dart';

class ReadAccount extends StatefulWidget {
  const ReadAccount({Key? key}) : super(key: key);

  @override
  State<ReadAccount> createState() => _ReadAccountState();
}

class _ReadAccountState extends State<ReadAccount> {
  final User user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Owner>>(
            stream: readOwner(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Something Went Wrong ${snapshot.error}');
              } else if (snapshot.hasData) {
                final owner = snapshot.data!;
                if (owner.isEmpty) {
                  return UserPage(
                    userId: user.uid,
                    indexNo: 1,
                  );
                } else {
                  return CheckBusiness(
                    ownerID: owner.first.accountId,
                  );
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
