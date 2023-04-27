// ignore_for_file: file_names, avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qnywhere/model/business.dart';
import 'package:qnywhere/owner/addBusiness.dart';
import 'package:qnywhere/owner/ownerContinueQueuePage.dart';
import 'package:qnywhere/owner/ownerPage.dart';
import 'package:qnywhere/owner/ownerPreQueuePage.dart';

import '../model/service.dart';

class CheckQueuePage extends StatefulWidget {
  final String serviceId;
  final String buisnessid;
  final String serviceName;
  const CheckQueuePage(
      {Key? key,
      required this.serviceId,
      required this.buisnessid,
      required this.serviceName})
      : super(key: key);

  @override
  State<CheckQueuePage> createState() => _CheckQueuePageState();
}

class _CheckQueuePageState extends State<CheckQueuePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Service>>(
            stream: readService(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something Went Wrong');
              } else if (snapshot.hasData) {
                final service = snapshot.data!;

                if (service.first.inService == true) {
                  return ContinueQueuePage(
                    serviceId: widget.serviceId,
                    buisnessid: widget.buisnessid,
                    serviceName: widget.serviceName,
                  );
                } else {
                  return PreQueuePage(
                    serviceId: widget.serviceId,
                    buisnessid: widget.buisnessid,
                    serviceName: widget.serviceName,
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

  Stream<List<Service>> readService() {
    return FirebaseFirestore.instance
        .collection('Business Services')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['serviceId'].toString().contains(widget.serviceId))
            .map((doc) => Service.fromJson(doc.data()))
            .toList());
  }
}
