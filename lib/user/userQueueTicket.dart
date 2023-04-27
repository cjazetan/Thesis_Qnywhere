// ignore_for_file: file_name, avoid_print, file_names
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qnywhere/components/queueNotification.dart';
import 'package:qnywhere/model/business.dart';
import 'package:qnywhere/model/queue.dart';
import 'package:qnywhere/model/user.dart';
import 'package:qnywhere/user/userPage.dart';
import 'package:qnywhere/user/viewBusinessPage.dart';
import 'package:uuid/uuid.dart';

class QueueTicketPage extends StatefulWidget {
  const QueueTicketPage(
      {Key? key,
      required this.serviceId,
      required this.businessId,
      required this.queueId})
      : super(key: key);
  final String serviceId;
  final String businessId;
  final String queueId;
  @override
  State<QueueTicketPage> createState() => _QueueTicketPageState();
}

class _QueueTicketPageState extends State<QueueTicketPage> {
  final User user = FirebaseAuth.instance.currentUser!;
  Duration duration = const Duration();
  Timer? timer;
  int difference = 0;
  String businessNotifId = "";
  var uuid = const Uuid();
  void getDuration() async {
    var collection = FirebaseFirestore.instance.collection('Queue Tickets');
    var docSnapshot = await collection.doc(widget.queueId).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();

      var estimatedTime = data?['estimatedTime'];
      final DateTime dateTimeQueued = DateTime.now();
      final DateTime dateEstimatedTime = DateTime.fromMicrosecondsSinceEpoch(
          estimatedTime.microsecondsSinceEpoch);
      final difference = dateEstimatedTime.difference(dateTimeQueued);
      this.difference = difference.inMinutes;
      if (difference.inSeconds.isNegative) {
        setState(() {
          duration = Duration(seconds: 0);
        });
      } else {
        setState(() {
          duration = Duration(minutes: this.difference);
        });
      }
    }
  }

  void listenNotification() =>
      QueueNotification.onNotifications.stream.listen(onClickedNotification);
  void onClickedNotification(String? payload) {}

  void addTime() {
    const minusSeconds = -1;
    setState(() {
      if (duration.inSeconds == 0) {
        setState(() {
          timer?.cancel();
        });
      } else {
        final seconds = duration.inSeconds + minusSeconds;
        duration = Duration(seconds: seconds);
      }
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  @override
  void initState() {
    QueueNotification.init();
    listenNotification();
    super.initState();
    getDuration();
    startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff294243),
      body: SafeArea(
        child: StreamBuilder<List<Queue>>(
            stream: readQueue(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print("Queue: ${snapshot.error}");
                return Text('Something Went Wrong ${snapshot.error}');
              } else if (snapshot.hasData) {
                final userQueue = snapshot.data!;
                if (userQueue.first.isDone == true) {
                  timer!.cancel();
                  if (userQueue.first.isCancelCustomer == true) {
                    return Stack(
                      children: [
                        Positioned(
                          top: 1,
                          child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.21,
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                // ignore: prefer_const_literals_to_create_immutables
                                children: [
                                  const Text(
                                    "YOU HAVE CANCELLED YOUR TICKET",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text(
                                    "Sorry for the inconvenience please try again next time",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        color: Colors.white),
                                  ),
                                ],
                              )),
                        ),
                        Positioned(
                          bottom: 1,
                          child: Container(
                              height: MediaQuery.of(context).size.height * 0.75,
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Color.fromRGBO(41, 66, 67, 100),
                                      Color.fromRGBO(57, 142, 127, 100),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0),
                                  )),
                              child: StreamBuilder<List<Users>>(
                                stream: readUser(),
                                builder: ((context, snapshot) {
                                  if (snapshot.hasError) {
                                    print("user: ${snapshot.error}");
                                    return Text(
                                        'Something Went Wrong ${snapshot.error}');
                                  } else if (snapshot.hasData) {
                                    final currentUser = snapshot.data!;
                                    return StreamBuilder<List<Business>>(
                                      stream: readBusiness(),
                                      builder: ((context, snapshot) {
                                        if (snapshot.hasError) {
                                          print("Business: ${snapshot.error}");
                                          return const Text(
                                              'Something Went Wrong');
                                        } else if (snapshot.hasData) {
                                          final business = snapshot.data!;
                                          return StreamBuilder<List<Queue>>(
                                            stream: readQueue(),
                                            builder: ((context, snapshot) {
                                              if (snapshot.hasError) {
                                                print(
                                                    "Queue: ${snapshot.error}");
                                                return const Text(
                                                    'Something Went Wrong');
                                              } else if (snapshot.hasData) {
                                                final ticket = snapshot.data!;
                                                DateTime myDateTime = ticket
                                                    .first.timeQueued
                                                    .toDate();
                                                String formattedDate =
                                                    DateFormat.yMMMMd('en_US')
                                                        .format(myDateTime);
                                                String formattedTime =
                                                    DateFormat.jm()
                                                        .format(myDateTime);
                                                print(formattedDate);
                                                print(formattedTime);
                                                return Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 150,
                                                              vertical: 10),
                                                      child: Divider(
                                                        color: Colors.white,
                                                        thickness: 3,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 20,
                                                              bottom: 10),
                                                      child: Text(
                                                        'Hi ${currentUser.first.accountFirstName}!',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                            fontSize: 22),
                                                      ),
                                                    ),
                                                    const Text(
                                                      'Thank you for waiting',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.white,
                                                          fontSize: 20),
                                                    ),
                                                    const SizedBox(height: 30),
                                                    Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.52,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.80,
                                                      decoration: const BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 35),
                                                            child: Text(
                                                              business.first
                                                                  .businessName,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 26,
                                                                  color: Color(
                                                                      0xff294243)),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5),
                                                            child: Text(
                                                              business.first
                                                                  .businessLocation,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize: 16,
                                                                  color: Color(
                                                                      0xff294243)),
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10),
                                                            child: Divider(
                                                              color: Color(
                                                                  0xff294243),
                                                              thickness: 3,
                                                            ),
                                                          ),
                                                          Text(
                                                            (ticket.first
                                                                        .queueNumber <
                                                                    10)
                                                                ? "0${ticket.first.queueNumber.toString()}"
                                                                : ticket.first
                                                                    .queueNumber
                                                                    .toString(),
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 90,
                                                                color: Color(
                                                                    0xff294243)),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom: 10,
                                                                    right: 75,
                                                                    left: 75),
                                                            child: Divider(
                                                              color: Color(
                                                                  0xff294243),
                                                              thickness: 1,
                                                            ),
                                                          ),
                                                          const Text(
                                                            "Queue Ticket Cancelled",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 16,
                                                                color: Color(
                                                                    0xff294243)),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 30),
                                                            child: Text(
                                                              "$formattedDate\n $formattedTime",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                  color: Color(
                                                                      0xff294243)),
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 5),
                                                            child: Divider(
                                                              color: Color(
                                                                  0xff294243),
                                                              thickness: 3,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                );
                                              } else {
                                                return const Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              }
                                            }),
                                          );
                                        } else {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                      }),
                                    );
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                }),
                              )),
                        ),
                        Positioned(
                            left: 1,
                            top: 1,
                            child: IconButton(
                              onPressed: (() {
                                Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                        builder: (context) => ViewBusinessPage(
                                              businessId: widget.businessId,
                                            )));
                              }),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 24,
                              ),
                            )),
                      ],
                    );
                  } else {
                    return Stack(
                      children: [
                        Positioned(
                          top: 1,
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.21,
                            width: MediaQuery.of(context).size.width,
                            child: (userQueue.first.isCancel == true)
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    // ignore: prefer_const_literals_to_create_immutables
                                    children: [
                                      const Text(
                                        "YOUR TICKET HAS BEEN CANCELLED",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        "Sorry for the inconvenience please try again next time",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                            color: Colors.white),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "IT'S YOUR TURN",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40,
                                            color: Colors.white),
                                      ),
                                      (userQueue.first.hasInstruction == true)
                                          ? Text(
                                              userQueue.first.instruction,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 22,
                                                  color: Colors.white),
                                            )
                                          : Text(
                                              "Please proceed to the ${userQueue.first.serviceName}",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 22,
                                                  color: Colors.white),
                                            ),
                                    ],
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 1,
                          child: Container(
                              height: MediaQuery.of(context).size.height * 0.75,
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Color.fromRGBO(41, 66, 67, 100),
                                      Color.fromRGBO(57, 142, 127, 100),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0),
                                  )),
                              child: StreamBuilder<List<Users>>(
                                stream: readUser(),
                                builder: ((context, snapshot) {
                                  if (snapshot.hasError) {
                                    print("user: ${snapshot.error}");
                                    return const Text('Something Went Wrong');
                                  } else if (snapshot.hasData) {
                                    final currentUser = snapshot.data!;
                                    return StreamBuilder<List<Business>>(
                                      stream: readBusiness(),
                                      builder: ((context, snapshot) {
                                        if (snapshot.hasError) {
                                          print("Business: ${snapshot.error}");
                                          return const Text(
                                              'Something Went Wrong');
                                        } else if (snapshot.hasData) {
                                          final business = snapshot.data!;
                                          return StreamBuilder<List<Queue>>(
                                            stream: readQueue(),
                                            builder: ((context, snapshot) {
                                              if (snapshot.hasError) {
                                                print(
                                                    "Queue: ${snapshot.error}");
                                                return const Text(
                                                    'Something Went Wrong');
                                              } else if (snapshot.hasData) {
                                                final ticket = snapshot.data!;
                                                DateTime myDateTime = ticket
                                                    .first.timeQueued
                                                    .toDate();
                                                String formattedDate =
                                                    DateFormat.yMMMMd('en_US')
                                                        .format(myDateTime);
                                                String formattedTime =
                                                    DateFormat.jm()
                                                        .format(myDateTime);
                                                print(formattedDate);
                                                print(formattedTime);
                                                return Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 150,
                                                              vertical: 10),
                                                      child: Divider(
                                                        color: Colors.white,
                                                        thickness: 3,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 20,
                                                              bottom: 10),
                                                      child: Text(
                                                        'Hi ${currentUser.first.accountFirstName}!',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                            fontSize: 22),
                                                      ),
                                                    ),
                                                    const Text(
                                                      'Thank you for waiting',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.white,
                                                          fontSize: 20),
                                                    ),
                                                    const SizedBox(height: 30),
                                                    Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.52,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.80,
                                                      decoration: const BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 35),
                                                            child: Text(
                                                              business.first
                                                                  .businessName,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 26,
                                                                  color: Color(
                                                                      0xff294243)),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5),
                                                            child: Text(
                                                              business.first
                                                                  .businessLocation,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize: 16,
                                                                  color: Color(
                                                                      0xff294243)),
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10),
                                                            child: Divider(
                                                              color: Color(
                                                                  0xff294243),
                                                              thickness: 3,
                                                            ),
                                                          ),
                                                          Text(
                                                            (ticket.first
                                                                        .queueNumber <
                                                                    10)
                                                                ? "0${ticket.first.queueNumber.toString()}"
                                                                : ticket.first
                                                                    .queueNumber
                                                                    .toString(),
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 90,
                                                                color: Color(
                                                                    0xff294243)),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom: 10,
                                                                    right: 75,
                                                                    left: 75),
                                                            child: Divider(
                                                              color: Color(
                                                                  0xff294243),
                                                              thickness: 1,
                                                            ),
                                                          ),
                                                          const Text(
                                                            "CURRENTLY SERVING YOU",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 16,
                                                                color: Color(
                                                                    0xff294243)),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 30),
                                                            child: Text(
                                                              "$formattedDate\n $formattedTime",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                  color: Color(
                                                                      0xff294243)),
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 5),
                                                            child: Divider(
                                                              color: Color(
                                                                  0xff294243),
                                                              thickness: 3,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                );
                                              } else {
                                                return const Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              }
                                            }),
                                          );
                                        } else {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                      }),
                                    );
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                }),
                              )),
                        ),
                        Positioned(
                            left: 1,
                            top: 1,
                            child: IconButton(
                              onPressed: (() {
                                Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                        builder: (context) => ViewBusinessPage(
                                              businessId: widget.businessId,
                                            )));
                              }),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 24,
                              ),
                            )),
                      ],
                    );
                  }
                } else {
                  return Stack(
                    children: [
                      Positioned(
                        top: 1,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.21,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              buildTime(),
                              const Text(
                                "ESTIMATED TIME LEFT",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 1,
                        child: Container(
                            height: MediaQuery.of(context).size.height * 0.75,
                            width: MediaQuery.of(context).size.width,
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Color.fromRGBO(41, 66, 67, 100),
                                    Color.fromRGBO(57, 142, 127, 100),
                                  ],
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                )),
                            child: StreamBuilder<List<Users>>(
                              stream: readUser(),
                              builder: ((context, snapshot) {
                                if (snapshot.hasError) {
                                  print("user: ${snapshot.error}");
                                  return const Text('Something Went Wrong');
                                } else if (snapshot.hasData) {
                                  final currentUser = snapshot.data!;
                                  return StreamBuilder<List<Business>>(
                                    stream: readBusiness(),
                                    builder: ((context, snapshot) {
                                      if (snapshot.hasError) {
                                        print("Business: ${snapshot.error}");
                                        return const Text(
                                            'Something Went Wrong');
                                      } else if (snapshot.hasData) {
                                        final business = snapshot.data!;
                                        return StreamBuilder<List<Queue>>(
                                          stream: readQueue(),
                                          builder: ((context, snapshot) {
                                            if (snapshot.hasError) {
                                              print("Queue: ${snapshot.error}");
                                              return const Text(
                                                  'Something Went Wrong');
                                            } else if (snapshot.hasData) {
                                              final ticket = snapshot.data!;
                                              DateTime myDateTime = ticket
                                                  .first.timeQueued
                                                  .toDate();
                                              String formattedDate =
                                                  DateFormat.yMMMMd('en_US')
                                                      .format(myDateTime);
                                              String formattedTime =
                                                  DateFormat.jm()
                                                      .format(myDateTime);
                                              print(formattedDate);
                                              print(formattedTime);
                                              return Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 150,
                                                            vertical: 10),
                                                    child: Divider(
                                                      color: Colors.white,
                                                      thickness: 3,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 20,
                                                            bottom: 10),
                                                    child: Text(
                                                      'Hi ${currentUser.first.accountFirstName}!',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          fontSize: 22),
                                                    ),
                                                  ),
                                                  const Text(
                                                    'Thank you for waiting',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white,
                                                        fontSize: 20),
                                                  ),
                                                  const SizedBox(height: 30),
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.52,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.80,
                                                    decoration: const BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20))),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 35),
                                                          child: Text(
                                                            business.first
                                                                .businessName,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 26,
                                                                color: Color(
                                                                    0xff294243)),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 5),
                                                          child: Text(
                                                            business.first
                                                                .businessLocation,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 16,
                                                                color: Color(
                                                                    0xff294243)),
                                                          ),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10),
                                                          child: Divider(
                                                            color: Color(
                                                                0xff294243),
                                                            thickness: 3,
                                                          ),
                                                        ),
                                                        Text(
                                                          (ticket.first
                                                                      .queueNumber <
                                                                  10)
                                                              ? "0${ticket.first.queueNumber.toString()}"
                                                              : ticket.first
                                                                  .queueNumber
                                                                  .toString(),
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 90,
                                                              color: Color(
                                                                  0xff294243)),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  bottom: 10,
                                                                  right: 75,
                                                                  left: 75),
                                                          child: Divider(
                                                            color: Color(
                                                                0xff294243),
                                                            thickness: 1,
                                                          ),
                                                        ),
                                                        Text(
                                                          (ticket.first
                                                                      .queueNumber <
                                                                  11)
                                                              ? "0${ticket.first.queueNumber - 1} CUSTOMERS WAITING"
                                                              : "${ticket.first.queueNumber - 1} CUSTOMERS WAITING",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 16,
                                                              color: Color(
                                                                  0xff294243)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 30),
                                                          child: Text(
                                                            "$formattedDate\n $formattedTime",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                                color: Color(
                                                                    0xff294243)),
                                                          ),
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 5),
                                                          child: Divider(
                                                            color: Color(
                                                                0xff294243),
                                                            thickness: 3,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              );
                                            } else {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }
                                          }),
                                        );
                                      } else {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                    }),
                                  );
                                } else {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                              }),
                            )),
                      ),
                      Positioned(
                          left: 1,
                          top: 1,
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
                      Positioned(
                          right: 1,
                          top: 1,
                          child: IconButton(
                            onPressed: (() {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 0,
                                      backgroundColor: Colors.transparent,
                                      child: contentBox(context),
                                    );
                                  });
                            }),
                            icon: const Icon(
                              Icons.cancel_sharp,
                              color: Colors.white,
                              size: 24,
                            ),
                          )),
                    ],
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
                "Cancel Ticket",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Are you sure you want to cancel your current queue?",
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 15,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () async {
                          Timestamp myTimeStamp =
                              Timestamp.fromDate(DateTime.now());
                          final docQueue = FirebaseFirestore.instance
                              .collection('Queue Tickets')
                              .doc(widget.queueId);
                          final data = {
                            "isCancelCustomer": true,
                            "isDone": true,
                          };
                          docQueue.update(data);
                          final userAccountDetails = await FirebaseFirestore
                              .instance
                              .collection('User Accounts')
                              .where('accountID', isEqualTo: user.uid)
                              .get();

                          for (var doc in userAccountDetails.docs) {
                            Map<String, dynamic> data = doc.data();
                            String firstName = data['accountFirstName'];
                            String lastName = data['accountLastName'];

                            final docUserAccount = FirebaseFirestore.instance
                                .collection('User Accounts')
                                .doc(user.uid);
                            final docUserAccountData = {
                              'inQueue': false,
                              'queueBusiness': "",
                            };
                            docUserAccount.update(docUserAccountData);

                            final serviceAccountDetails =
                                await FirebaseFirestore.instance
                                    .collection('Business Services')
                                    .where('serviceId',
                                        isEqualTo: widget.serviceId)
                                    .get();

                            for (var doc in serviceAccountDetails.docs) {
                              Map<String, dynamic> data = doc.data();
                              String serviceName = data['serviceName'];

                              businessNotifId = uuid.v4();
                              final docBusinessNotify = FirebaseFirestore
                                  .instance
                                  .collection('Business Notifications')
                                  .doc(businessNotifId);
                              final docBusinessNotifyData = {
                                'notificationId': businessNotifId,
                                'userId': user.uid,
                                'businessName': widget.businessId,
                                'serviceId': widget.serviceId,
                                'serviceName': serviceName,
                                'text':
                                    "$firstName $lastName has cancelled his/her queue from the $serviceName service ",
                                'dateCreated': myTimeStamp,
                              };
                              docBusinessNotify.set(docBusinessNotifyData);
                            }
                          }
                          setState(() {});
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Yes",
                          style: TextStyle(fontSize: 18),
                        )),
                    SizedBox(width: 10),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "No",
                          style: TextStyle(fontSize: 18),
                        )),
                  ],
                ),
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

  Text buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return Text(
      '$minutes:$seconds',
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 50, color: Colors.white),
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

  Stream<List<Users>> readUser() {
    return FirebaseFirestore.instance
        .collection('User Accounts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['accountID'].toString().contains(user.uid))
            .map((doc) => Users.fromJson(doc.data()))
            .toList());
  }

  Stream<List<Queue>> readQueue() {
    return FirebaseFirestore.instance
        .collection('Queue Tickets')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['queueId'].toString().contains(widget.queueId))
            .map((doc) => Queue.fromJson(doc.data()))
            .toList());
  }
}
