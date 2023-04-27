// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qnywhere/model/business.dart';
import 'package:qnywhere/model/service.dart';
import 'package:qnywhere/user/userPage.dart';
import 'package:qnywhere/user/viewBusinessPage.dart';
import 'package:qnywhere/utilities/search_widget.dart';

class BusinessLiveQueue extends StatefulWidget {
  final String businessId;
  const BusinessLiveQueue({Key? key, required this.businessId})
      : super(key: key);

  @override
  State<BusinessLiveQueue> createState() => _BusinessLiveQueueState();
}

class _BusinessLiveQueueState extends State<BusinessLiveQueue> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace:
            Container(decoration: const BoxDecoration(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 24,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => ViewBusinessPage(
                      businessId: widget.businessId,
                    )));
          },
        ),
        elevation: 0,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Text(
              "Live Queue",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Service>>(
          stream: readService(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something Went Wrong');
            } else if (snapshot.hasData) {
              final services = snapshot.data!;

              return ListView(children: services.map(buildLiveQueue).toList());
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Widget buildLiveQueue(Service service) => Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 15),
      child: Container(
        height: 200,
        width: MediaQuery.of(context).size.width * 0.80,
        decoration: BoxDecoration(
          color: Color(0xff398E7F),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.38,
              child: Center(
                child: Text(
                  service.serviceName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            VerticalDivider(
              color: Colors.white,
              thickness: 5,
              indent: 40,
              endIndent: 40,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.38,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Now Serving",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                        color: Colors.white),
                  ),
                  Text(
                    service.serving,
                    style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )
                ],
              ),
            )
          ],
        ),
      ));

  Stream<List<Service>> readService() {
    return FirebaseFirestore.instance
        .collection('Business Services')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['businessId'].toString().contains(widget.businessId))
            .map((doc) => Service.fromJson(doc.data()))
            .toList());
  }
}
