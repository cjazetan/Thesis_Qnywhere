// ignore_for_file: unnecessary_const, avoid_single_cascade_in_expression_statements, avoid_print, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qnywhere/model/business.dart';
import 'package:qnywhere/model/queue.dart';
import 'package:qnywhere/model/service.dart';
import 'package:qnywhere/user/businessLiveQueue.dart';
import 'package:qnywhere/user/userPage.dart';
import 'package:qnywhere/user/userQueueTicket.dart';
import 'package:qnywhere/user/viewServicePage.dart';

class ViewBusinessPage extends StatefulWidget {
  final String businessId;
  const ViewBusinessPage({Key? key, required this.businessId})
      : super(key: key);

  @override
  State<ViewBusinessPage> createState() => _ViewBusinessPageState();
}

class _ViewBusinessPageState extends State<ViewBusinessPage> {
  final User user = FirebaseAuth.instance.currentUser!;
  String queueBusiness = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
            backgroundColor: const Color(0xff294243),
            indicatorShape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            indicatorColor: Colors.grey,
            labelTextStyle: MaterialStateProperty.all(
                const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
        child: NavigationBar(
            height: 80,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            selectedIndex: 1,
            onDestinationSelected: (index) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => UserPage(
                        indexNo: index,
                        userId: user.uid,
                      )));
            },
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.person, size: 30, color: Colors.white),
                  label: 'Profile'),
              NavigationDestination(
                icon: Icon(Icons.home, size: 30, color: Colors.white),
                label: 'Home',
              ),
              NavigationDestination(
                  icon:
                      Icon(Icons.notifications, size: 30, color: Colors.white),
                  label: 'Notifications'),
            ]),
      ),
      body: StreamBuilder<List<Business>>(
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
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: MediaQuery.of(context).size.width,
                      child: Image.network(business.first.businessImageUrl,
                          height: MediaQuery.of(context).size.height * 0.43,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.fill),
                    ),
                    Positioned(
                      top: 20,
                      right: 1,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                                  builder: (context) => BusinessLiveQueue(
                                        businessId: widget.businessId,
                                      )));
                        },
                        child: const Text(
                          'Live Queue',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Color.fromRGBO(255, 255, 255, 0.6),
                            fixedSize: const Size(120, 40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50))),
                      ),
                    ),
                    Positioned(
                      bottom: 1,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.48,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            )),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Text(business.first.businessName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      color: Color(0xff294243))),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 19,
                                      color: Color(0xff294243),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      business.first.businessLocation,
                                      style: const TextStyle(
                                          color: Color(0xff294243),
                                          fontSize: 18),
                                    )
                                  ],
                                )),
                            const SizedBox(height: 20),
                            StreamBuilder<List<Service>>(
                                stream: readService(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    print("readService: ${snapshot.error}");
                                    return const Text('Something Went Wrong');
                                  } else if (snapshot.hasData) {
                                    final service = snapshot.data!;
                                    print(service.length);
                                    print(widget.businessId);
                                    if (service.isNotEmpty) {
                                      return StreamBuilder<List<Queue>>(
                                          stream: readQueue(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              print(
                                                  "readQueue: ${snapshot.error}");
                                              return const Text(
                                                  'Something Went Wrong');
                                            } else if (snapshot.hasData) {
                                              final users = snapshot.data!;

                                              return SizedBox(
                                                height: 220,
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: service.length,
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  itemBuilder: (context, i) {
                                                    return GestureDetector(
                                                      onTap: () async {
                                                        final userAccountDetails =
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'User Accounts')
                                                                .where(
                                                                    'accountID',
                                                                    isEqualTo:
                                                                        user.uid)
                                                                .get();

                                                        for (var doc
                                                            in userAccountDetails
                                                                .docs) {
                                                          Map<String, dynamic>
                                                              data = doc.data();
                                                          bool inQueue =
                                                              data['inQueue'];
                                                          queueBusiness = data[
                                                              'queueBusiness'];

                                                          if (inQueue ==
                                                                  false ||
                                                              queueBusiness ==
                                                                  widget
                                                                      .businessId) {
                                                            final useQueueTicket = await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Queue Tickets')
                                                                .where(
                                                                    "accountId",
                                                                    isEqualTo:
                                                                        user
                                                                            .uid)
                                                                .where("isDone",
                                                                    isEqualTo:
                                                                        false)
                                                                .where(
                                                                    "isCancel",
                                                                    isEqualTo:
                                                                        false)
                                                                .where(
                                                                    "serviceId",
                                                                    isEqualTo:
                                                                        service[i]
                                                                            .serviceId)
                                                                .get();

                                                            if (useQueueTicket
                                                                .docs
                                                                .isNotEmpty) {
                                                              for (var accoundDoc
                                                                  in useQueueTicket
                                                                      .docs) {
                                                                Map<String,
                                                                        dynamic>
                                                                    data =
                                                                    accoundDoc
                                                                        .data();
                                                                String queueId =
                                                                    data[
                                                                        'queueId'];

                                                                Navigator.of(
                                                                        context)
                                                                    .push(MaterialPageRoute(
                                                                        builder: (context) => QueueTicketPage(
                                                                              businessId: widget.businessId,
                                                                              serviceId: service[i].serviceId,
                                                                              queueId: queueId,
                                                                            )));
                                                              }
                                                            } else {
                                                              print(
                                                                  "Not Found");
                                                              Navigator.of(
                                                                      context)
                                                                  .pushReplacement(
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              ViewServicePage(
                                                                                businessId: widget.businessId,
                                                                                serviceId: service[i].serviceId,
                                                                              )));
                                                            }
                                                          } else {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return Dialog(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                    ),
                                                                    elevation:
                                                                        0,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    child: contentBox(
                                                                        context),
                                                                  );
                                                                });
                                                          }
                                                        }
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 10),
                                                        child: Container(
                                                          height: 220,
                                                          width: 130,
                                                          decoration:
                                                              const BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                    begin: Alignment
                                                                        .bottomCenter,
                                                                    end: Alignment
                                                                        .topCenter,
                                                                    colors: [
                                                                      Color.fromRGBO(
                                                                          41,
                                                                          66,
                                                                          67,
                                                                          100),
                                                                      Color.fromRGBO(
                                                                          57,
                                                                          142,
                                                                          127,
                                                                          100),
                                                                    ],
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20))),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                service[i]
                                                                    .serviceName,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        22,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              const SizedBox(
                                                                  height: 5),
                                                              const Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            20),
                                                                child:
                                                                    const Divider(
                                                                  color: Colors
                                                                      .white,
                                                                  thickness: 3,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
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
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        left: 10,
                        top: 20,
                        child: IconButton(
                          onPressed: (() {
                            Navigator.of(context).pop();
                          }),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        )),
                  ],
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
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
                element['businessId'].toString().contains(widget.businessId))
            .map((doc) => Service.fromJson(doc.data()))
            .toList());
  }

  Stream<List<Queue>> readQueue() {
    return FirebaseFirestore.instance
        .collection('Queue Tickets')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['accountId'].toString().contains(user.uid))
            .map((doc) => Queue.fromJson(doc.data()))
            .toList());
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(
              left: 20, top: 45 + 20, right: 20, bottom: 20),
          margin: const EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Pending Queues",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "You still have pending queues from other business please complete those transactions before queuing to another business",
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 15,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Close",
                      style: TextStyle(fontSize: 18),
                    )),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 55,
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(55)),
                child: Image.asset("assets/images/hero.png")),
          ),
        ),
      ],
    );
  }
}
