// ignore_for_file: unnecessary_const, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qnywhere/model/business.dart';
import 'package:qnywhere/model/queue.dart';
import 'package:qnywhere/model/service.dart';
import 'package:qnywhere/model/user.dart';
import 'package:qnywhere/user/userQueueTicket.dart';
import 'package:qnywhere/user/viewBusinessPage.dart';
import 'package:uuid/uuid.dart';

class ViewServicePage extends StatefulWidget {
  final String serviceId;
  final String businessId;
  const ViewServicePage(
      {Key? key, required this.serviceId, required this.businessId})
      : super(key: key);

  @override
  State<ViewServicePage> createState() => _ViewServicePageState();
}

class _ViewServicePageState extends State<ViewServicePage> {
  final User user = FirebaseAuth.instance.currentUser!;
  String service = "";
  var uuid = const Uuid();
  String ticketUID = "";
  String userNotifId = "";
  String businessNotifId = "";
  int queueNumber = 0;
  String serviceName = "";
  String businessNameData = "";
  String businessIdData = "";
  double queueMinutes = 0;
  String firstName = "";
  String lastName = "";
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [
              Color.fromRGBO(41, 66, 67, 100),
              Color.fromRGBO(57, 142, 127, 100),
            ],
          ),
        ),
        child: StreamBuilder<List<Business>>(
            stream: readBusiness(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something Went Wrong');
              } else if (snapshot.hasData) {
                final business = snapshot.data!;
                return SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.45,
                        width: MediaQuery.of(context).size.width,
                      ),
                      Positioned(
                        bottom: 1,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.53,
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              )),
                          child: StreamBuilder<List<Service>>(
                              stream: readService(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Text('Something Went Wrong');
                                } else if (snapshot.hasData) {
                                  final service = snapshot.data!;
                                  this.service = service.first.serviceId;
                                  serviceName = service.first.serviceName;
                                  if (service.isNotEmpty) {
                                    return StreamBuilder<List<Queue>>(
                                        stream: readQueue(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return const Text(
                                                'Something Went Wrong');
                                          } else if (snapshot.hasData) {
                                            final queue = snapshot.data!;
                                            String line;

                                            if (queue.isEmpty) {
                                              line = "0";
                                            } else {
                                              line = queue.length.toString();
                                            }
                                            double queueToMinutues =
                                                double.parse(service
                                                        .first.waitingTime) /
                                                    60;
                                            queueMinutes = queueToMinutues *
                                                double.parse(line);
                                            queueNumber = int.parse(line) + 1;
                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 50),
                                                  child: Text(
                                                      business
                                                          .first.businessName,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: 28,
                                                          color: Color(
                                                              0xff294243))),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10, bottom: 25),
                                                  child: Text(
                                                    service.first.serviceName,
                                                    style: const TextStyle(
                                                        color: const Color(
                                                            0xff294243),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 40),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              right: 5),
                                                      child: Container(
                                                        width: 50.0,
                                                        height: 50.0,
                                                        decoration:
                                                            const BoxDecoration(
                                                          gradient:
                                                              const LinearGradient(
                                                            begin: Alignment
                                                                .bottomCenter,
                                                            end: Alignment
                                                                .topCenter,
                                                            colors: [
                                                              Color.fromRGBO(41,
                                                                  66, 67, 100),
                                                              Color.fromRGBO(
                                                                  57,
                                                                  142,
                                                                  127,
                                                                  100),
                                                            ],
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            line.toString(),
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 22,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Column(
                                                      children: const [
                                                        Text(
                                                          "People",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff294243),
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          "in front of you",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff294243),
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20,
                                                              right: 5),
                                                      child: Container(
                                                        width: 50.0,
                                                        height: 50.0,
                                                        decoration:
                                                            const BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            begin: Alignment
                                                                .bottomCenter,
                                                            end: Alignment
                                                                .topCenter,
                                                            colors: [
                                                              Color.fromRGBO(41,
                                                                  66, 67, 100),
                                                              const Color
                                                                      .fromRGBO(
                                                                  57,
                                                                  142,
                                                                  127,
                                                                  100),
                                                            ],
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            queueMinutes
                                                                .toString(),
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 22,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Column(
                                                      children: const [
                                                        Text(
                                                          "Minutes",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff294243),
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          "Estimated time",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff294243),
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                        Text(
                                                          "before your turn",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff294243),
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 40),
                                                Center(child: addQueue(size)),
                                                const SizedBox(height: 25),
                                                const Divider(
                                                  color: Color(0xff294243),
                                                  thickness: 2,
                                                )
                                              ],
                                            );
                                          } else {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                        });
                                  } else {
                                    return Container();
                                  }
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              }),
                        ),
                      ),
                      Positioned(
                          left: 1,
                          top: 1,
                          child: IconButton(
                            onPressed: (() {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => ViewBusinessPage(
                                          businessId: widget.businessId)));
                            }),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          )),
                      Positioned(
                        top: 80,
                        left: 40,
                        child: Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                  business.first.businessImageUrl,
                                  height: 200,
                                  width: 160,
                                  fit: BoxFit.fill),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
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

  InkWell addQueue(Size size) {
    String mobileNumber = "";

    return InkWell(
      onTap: (() async {
        var retrievedData =
            FirebaseFirestore.instance.collection('User Accounts');
        var docSnapshot = await retrievedData.doc(user.uid).get();
        if (docSnapshot.exists) {
          Map<String, dynamic> data = docSnapshot.data()!;

          // You can then retrieve the value from the Map like this:
          firstName = data['accountFirstName'];
          lastName = data['accountLastName'];
          mobileNumber = data['accountPhoneNumber'];
        }
        ticketUID = uuid.v4();
        final uploadTime = DateTime.now();
        Timestamp myTimeStamp = Timestamp.fromDate(uploadTime);
        final estimatedTime =
            uploadTime.add(Duration(minutes: queueMinutes.toInt()));
        Timestamp estimatedTimeStamp = Timestamp.fromDate(estimatedTime);
        final docQueue = FirebaseFirestore.instance
            .collection('Queue Tickets')
            .doc(ticketUID);
        final data = {
          'queueId': ticketUID,
          'serviceName': serviceName,
          'queueNumber': queueNumber,
          'serviceId': widget.serviceId,
          'businessId': widget.businessId,
          'accountId': user.uid,
          'timeQueued': myTimeStamp,
          'estimatedTime': estimatedTimeStamp,
          'fullName': "$firstName $lastName",
          'mobileNumber': mobileNumber,
          "servingDuration": "0",
          "waitingDuration": "0",
          "isCancel": false,
          "hasInstruction": false,
          "isDone": false,
          "isRemoved": false,
          "instruction": "",
          "isNotifiedCancelled": false,
          "notiyfNextInLine": false,
          "notiyfTurnComingUp": false,
          "isCancelCustomer": false,
        };

        docQueue.set(data);

        final userAccountDetails = await FirebaseFirestore.instance
            .collection('User Accounts')
            .where('accountID', isEqualTo: user.uid)
            .get();

        for (var doc in userAccountDetails.docs) {
          Map<String, dynamic> data = doc.data();
          List<dynamic> mapRecentsRetrieved = data['recentQueued'];

          final businessAccountDetails = await FirebaseFirestore.instance
              .collection('Business Accounts')
              .where('businessId', isEqualTo: widget.businessId)
              .get();

          for (var doc in businessAccountDetails.docs) {
            Map<String, dynamic> data = doc.data();
            String businessImageUrlData = data['businessImageUrl'];
            String businessLocationData = data['businessLocation'];
            businessNameData = data['businessName'];
            businessIdData = data['businessId'];
            print("1st iteration ${mapRecentsRetrieved.length}");
            const String queueId = "queueId";
            const String businessId = "businessId";
            const String serviceId = "serviceId";
            const String businessImageUrl = "businessImageUrl";
            const String businessLocation = "businessLocation";
            const String businessName = "businessName";

            bool sameBusinessId = false;
            for (int i = 0; i < mapRecentsRetrieved.length; i++) {
              if (mapRecentsRetrieved[i]["businessId"] == businessIdData) {
                sameBusinessId = true;
              }
            }
            if (sameBusinessId == false) {
              mapRecentsRetrieved.add({
                queueId: "${widget.serviceId}${user.uid}",
                businessId: widget.businessId,
                serviceId: widget.serviceId,
                businessImageUrl: businessImageUrlData,
                businessLocation: businessLocationData,
                businessName: businessNameData,
              });
            } else {
              print("Business Info already saved");
            }
            print("2nd iteration ${mapRecentsRetrieved.length}");

            final docUser = FirebaseFirestore.instance
                .collection('User Accounts')
                .doc(user.uid);

            final userData = {
              'inQueue': true,
              'queueBusiness': widget.businessId,
              'recentQueued': mapRecentsRetrieved
            };

            docUser.update(userData);
          }
        }
        userNotifId = uuid.v4();
        final docNotify = FirebaseFirestore.instance
            .collection('User Notifications')
            .doc(userNotifId);
        final docNotifyData = {
          'notificationId': userNotifId,
          'userId': user.uid,
          'businessName': businessNameData,
          'text':
              "You have successfully queued in our $serviceName service, please take note of your queue number \"${queueNumber - 1}\"",
          'dateCreated': myTimeStamp,
          'serviceName': serviceName,
          'instruction': "",
          'hasIntruction': false,
        };

        businessNotifId = uuid.v4();
        final docBusinessNotify = FirebaseFirestore.instance
            .collection('Business Notifications')
            .doc(businessNotifId);
        final docBusinessNotifyData = {
          'notificationId': businessNotifId,
          'userId': user.uid,
          'businessName': widget.businessId,
          'serviceId': widget.serviceId,
          'serviceName': serviceName,
          'text':
              "$firstName $lastName successfuly queued for the $serviceName service with the queue number \"${queueNumber - 1}\"",
          'dateCreated': myTimeStamp,
        };

        docBusinessNotify.set(docBusinessNotifyData);

        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => QueueTicketPage(
                  businessId: widget.businessId,
                  serviceId: service,
                  queueId: ticketUID,
                )));
      }),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: size.width * 0.65,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color.fromARGB(255, 0, 33, 59),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        child: const Text(
          'Add Queue',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Stream<List<Business>> readBusiness() {
    return FirebaseFirestore.instance
        .collection('Business Accounts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['businessId'].toString().contains(widget.businessId))
            .map((doc) => Business.fromJson(doc.data()))
            .toList());
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

  Stream<List<Queue>> readQueue() {
    return FirebaseFirestore.instance
        .collection('Queue Tickets')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['serviceId'].toString().contains(widget.serviceId))
            .map((doc) => Queue.fromJson(doc.data()))
            .toList());
  }
}
