// ignore_for_file: file_names, avoid_print
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qnywhere/model/business.dart';
import 'package:qnywhere/model/queue.dart';
import 'package:qnywhere/model/service.dart';
import 'package:qnywhere/model/user.dart';
import 'package:qnywhere/owner/ownerPage.dart';

class OwnerQueuePage extends StatefulWidget {
  const OwnerQueuePage(
      {Key? key,
      required this.serviceId,
      required this.businessId,
      required this.serviceName})
      : super(key: key);
  final String serviceId;
  final String businessId;
  final String serviceName;

  @override
  State<OwnerQueuePage> createState() => _OwnerQueuePageState();
}

class _OwnerQueuePageState extends State<OwnerQueuePage> {
  final User user = FirebaseAuth.instance.currentUser!;
  TextEditingController instructionGiven = TextEditingController();
  Duration duration = const Duration();
  Timer? timer;
  String currentUserId = "";
  String savedDuration = "";
  String instruction = "";
  int difference = 0;
  String diffennceString = "";
  String currentQueueId = "";
  int servingNumber = 0;
  int queueLength = 0;
  void addTime() {
    const addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void reset() {
    setState(() {
      duration = const Duration();
    });
  }

  void stopTimer() {
    setState(() {
      timer?.cancel();
      savedDuration = duration.inSeconds.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xff294243),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 1,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.29,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                        colors: [
                      Color(0xff294243),
                      Color(0xff398E7F),
                    ])),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.serviceName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    buildTime(),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 1,
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.68,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      )),
                  child: StreamBuilder<List<Service>>(
                    stream: readService(),
                    builder: ((context, snapshot) {
                      if (snapshot.hasError) {
                        print("service: ${snapshot.error}");
                        return const Text('Something Went Wrong');
                      } else if (snapshot.hasData) {
                        final currentService = snapshot.data!;

                        servingNumber = int.parse(currentService.first.serving);
                        return StreamBuilder<List<Queue>>(
                          stream: readQueue(),
                          builder: ((context, snapshot) {
                            if (snapshot.hasError) {
                              print("Queue: ${snapshot.error}");
                              return const Text('Something Went Wrong');
                            } else if (snapshot.hasData) {
                              final currentQueue = snapshot.data!;
                              currentQueueId = currentQueue.first.queueId;
                              print(currentQueue);
                              print(currentQueue.first.accountId);
                              queueLength = currentQueue.length;
                              if (currentQueue.isNotEmpty) {
                                if (servingNumber <= currentQueue.length) {
                                  currentUserId = currentQueue[int.parse(
                                              currentService.first.serving) -
                                          1]
                                      .accountId;
                                } else {}
                              }

                              print(currentUserId);
                              if (servingNumber > currentQueue.length) {
                                timer?.cancel();
                                savedDuration = duration.inSeconds.toString();
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 20, bottom: 10),
                                      child: Text(
                                        "There are no customers waiting in line",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff294243),
                                            fontSize: 20),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 20, bottom: 10),
                                      child: Text(
                                        "Kindly wait for the next customer to queue thank you",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff294243),
                                            fontSize: 22),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return StreamBuilder<List<Users>>(
                                  stream: readUser(),
                                  builder: ((context, snapshot) {
                                    if (snapshot.hasError) {
                                      print("Users: ${snapshot.error}");
                                      return const Text('Something Went Wrong');
                                    } else if (snapshot.hasData) {
                                      int numberWaiting = currentQueue.length -
                                          currentQueue[int.parse(currentService
                                                      .first.serving) -
                                                  1]
                                              .queueNumber;
                                      if (numberWaiting < 0) {
                                        numberWaiting = 0;
                                      }
                                      final currentUser = snapshot.data!;
                                      if (currentQueue.first.isCancelCustomer ==
                                          true) {
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  top: 30, bottom: 10),
                                              child: Text(
                                                "QUEUE TICKET HAS BEEN CANCELLED",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xff294243),
                                                    fontSize: 20),
                                              ),
                                            ),
                                            Text(
                                              (int.parse(currentService
                                                          .first.serving) <
                                                      10)
                                                  ? "0${currentQueue[int.parse(currentService.first.serving) - 1].queueNumber}"
                                                  : currentService
                                                      .first.serving,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 120,
                                                  color: Color(0xff294243)),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  currentUser
                                                      .first.accountFirstName,
                                                  style: const TextStyle(
                                                      fontSize: 26,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xff294243)),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  currentUser
                                                      .first.accountLastName,
                                                  style: const TextStyle(
                                                      fontSize: 26,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xff294243)),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              currentUser
                                                  .first.accountPhoneNumber,
                                              style: const TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff294243)),
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              "THE CUSTOMER HAS CANCELLED HIS/HER TICKET",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.normal,
                                                  color: Color(0xff294243)),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: const [
                                                Text(
                                                  "PLEASE PROCEED TO THE NEXT CUSTOMER",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Color(0xff294243)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 40),
                                            Center(
                                                child: proceedQueue(
                                                    size,
                                                    currentQueue
                                                        .first.timeQueued)),
                                          ],
                                        );
                                      } else {
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  top: 30, bottom: 10),
                                              child: Text(
                                                "Next In Line",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xff294243),
                                                    fontSize: 26),
                                              ),
                                            ),
                                            Text(
                                              (int.parse(currentService
                                                          .first.serving) <
                                                      10)
                                                  ? "0${currentQueue[int.parse(currentService.first.serving) - 1].queueNumber}"
                                                  : currentService
                                                      .first.serving,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 120,
                                                  color: Color(0xff294243)),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  currentUser
                                                      .first.accountFirstName,
                                                  style: const TextStyle(
                                                      fontSize: 26,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xff294243)),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  currentUser
                                                      .first.accountLastName,
                                                  style: const TextStyle(
                                                      fontSize: 26,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xff294243)),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              currentUser
                                                  .first.accountPhoneNumber,
                                              style: const TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff294243)),
                                            ),
                                            const SizedBox(height: 40),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  numberWaiting.toString(),
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xff294243)),
                                                ),
                                                const SizedBox(width: 10),
                                                const Text(
                                                  "CUSTOMERS WAITING",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Color(0xff294243)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 40),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  height: 100,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  child: Center(
                                                      child: nextCustomer(
                                                          currentQueue.first
                                                              .timeQueued)),
                                                ),
                                                SizedBox(
                                                  height: 100,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  child: Center(
                                                      child: cancelCustomer(
                                                          currentQueue.first
                                                              .timeQueued)),
                                                )
                                              ],
                                            ),
                                          ],
                                        );
                                      }
                                    } else {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                  }),
                                );
                              }
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          }),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
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
          ],
        ),
      ),
    );
  }

  SizedBox nextCustomer(Timestamp timeQueued) {
    final DateTime currentTime = DateTime.now();
    final DateTime userTimeQueued =
        DateTime.fromMicrosecondsSinceEpoch(timeQueued.microsecondsSinceEpoch);
    final difference = userTimeQueued.difference(currentTime);
    this.difference = difference.inSeconds;
    diffennceString = this.difference.toString();
    return SizedBox.fromSize(
      size: const Size(100, 120), // button width and height
      child: ClipOval(
        child: Material(
          color: const Color(0xff294243), // button color
          child: InkWell(
            splashColor: const Color(0xff398E7F), // splash color
            onTap: () {
              openDialogNextButton();
            }, // button pressed
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ), // icon
                Text(
                  "Serve",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ), // text
              ],
            ),
          ),
        ),
      ),
    );
  }

  InkWell proceedQueue(Size size, Timestamp timeQueued) {
    final DateTime currentTime = DateTime.now();
    final DateTime userTimeQueued =
        DateTime.fromMicrosecondsSinceEpoch(timeQueued.microsecondsSinceEpoch);
    final difference = currentTime.difference(userTimeQueued);
    this.difference = difference.inSeconds;
    diffennceString = this.difference.toString();
    return InkWell(
      onTap: (() {
        timer?.cancel();
        savedDuration = duration.inSeconds.toString();
        print(savedDuration);
        print(queueLength);
        print(servingNumber);
        if (queueLength >= servingNumber) {
          final docTickets = FirebaseFirestore.instance
              .collection('Queue Tickets')
              .doc(currentQueueId);

          final queueData = {
            'servingDuration': savedDuration,
            'waitingDuration': diffennceString,
            'isDone': true,
            'isCancel': true,
          };
          docTickets.update(queueData);
          final docService = FirebaseFirestore.instance
              .collection('Business Services')
              .doc(widget.serviceId);
          print("serving number $servingNumber");
          final serviceData = {
            'serving': (servingNumber + 1).toString(),
          };
          docService.update(serviceData);
          reset();
          startTimer();
        } else {
          final docTickets = FirebaseFirestore.instance
              .collection('Queue Tickets')
              .doc(currentQueueId);

          final queueData = {
            'servingDuration': savedDuration,
            'waitingDuration': diffennceString,
            'isDone': true,
            'isCancel': true,
          };
          docTickets.update(queueData);
          reset();
          startTimer();
        }
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
          'PROCEED',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  SizedBox cancelCustomer(Timestamp timeQueued) {
    final DateTime currentTime = DateTime.now();
    final DateTime userTimeQueued =
        DateTime.fromMicrosecondsSinceEpoch(timeQueued.microsecondsSinceEpoch);
    final difference = currentTime.difference(userTimeQueued);
    this.difference = difference.inSeconds;
    diffennceString = this.difference.toString();
    return SizedBox.fromSize(
      size: const Size(100, 120), // button width and height
      child: ClipOval(
        child: Material(
          color: const Color(0xff294243), // button color
          child: InkWell(
            splashColor: const Color(0xff398E7F), // splash color
            onTap: () {
              timer?.cancel();
              savedDuration = duration.inSeconds.toString();
              print(savedDuration);
              print(queueLength);
              print(servingNumber);

              if (queueLength >= servingNumber) {
                final docTickets = FirebaseFirestore.instance
                    .collection('Queue Tickets')
                    .doc(currentQueueId);

                final queueData = {
                  'servingDuration': savedDuration,
                  'waitingDuration': diffennceString,
                  'isDone': true,
                  'isCancel': true,
                };
                docTickets.update(queueData);
                final docService = FirebaseFirestore.instance
                    .collection('Business Services')
                    .doc(widget.serviceId);
                print("serving number $servingNumber");
                final serviceData = {
                  'serving': (servingNumber + 1).toString(),
                };
                docService.update(serviceData);
                reset();
                startTimer();
              } else {
                final docTickets = FirebaseFirestore.instance
                    .collection('Queue Tickets')
                    .doc(currentQueueId);

                final queueData = {
                  'servingDuration': savedDuration,
                  'waitingDuration': diffennceString,
                  'isDone': true,
                  'isCancel': true,
                };
                docTickets.update(queueData);
                reset();
                startTimer();
              }
            }, // button pressed
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(
                  Icons.cancel,
                  color: Colors.white,
                  size: 40,
                ), // icon
                Text(
                  "Cancel",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ), // text
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future openDialogNextButton() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            backgroundColor: const Color(0xff398E7F),
            title: const Text(
              'Queue Preparation for the next person',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            content: const SizedBox(
                height: 55,
                width: double.minPositive,
                child: Text(
                  "Do you want to give a set of instructions to the person next in line?",
                  style: TextStyle(color: Colors.white),
                )),
            actions: [
              TextButton(
                  onPressed: (() {
                    timer?.cancel();
                    savedDuration = duration.inSeconds.toString();
                    openDialogGiveInstruction();
                  }),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xff294243),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                  ),
                  child: const Text(
                    'Yes',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  )),
              TextButton(
                  onPressed: (() {
                    timer?.cancel();
                    savedDuration = duration.inSeconds.toString();
                    if (queueLength >= servingNumber) {
                      final docTickets = FirebaseFirestore.instance
                          .collection('Queue Tickets')
                          .doc(currentQueueId);

                      final queueData = {
                        'servingDuration': savedDuration,
                        'waitingDuration': diffennceString,
                        'isDone': true,
                      };
                      docTickets.update(queueData);
                      final docService = FirebaseFirestore.instance
                          .collection('Business Services')
                          .doc(widget.serviceId);
                      print("serving number $servingNumber");
                      final serviceData = {
                        'serving': (servingNumber + 1).toString(),
                      };
                      docService.update(serviceData);
                      reset();
                      startTimer();
                    } else {
                      final docTickets = FirebaseFirestore.instance
                          .collection('Queue Tickets')
                          .doc(currentQueueId);

                      final queueData = {
                        'servingDuration': savedDuration,
                        'waitingDuration': diffennceString,
                        'isDone': true,
                      };
                      docTickets.update(queueData);
                      reset();
                      startTimer();
                    }

                    Navigator.of(context).pop();
                  }),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xff294243),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                  ),
                  child: const Text(
                    'No',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  )),
            ],
          ));

  Future openDialogGiveInstruction() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            backgroundColor: const Color(0xff398E7F),
            title: const Text(
              'Give Instructions',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              height: 50,
              width: double.minPositive,
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 18),
                keyboardType: TextInputType.emailAddress,
                controller: instructionGiven,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xff398E7F),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(width: 1, color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.white),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.white),
                      borderRadius: BorderRadius.circular(15),
                    )),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: (() {
                    print(savedDuration);
                    print(queueLength);
                    print(servingNumber);

                    if (queueLength > servingNumber) {
                      final docTickets = FirebaseFirestore.instance
                          .collection('Queue Tickets')
                          .doc(currentQueueId);

                      final queueData = {
                        'servingDuration': savedDuration,
                        'waitingDuration': diffennceString,
                        'isDone': true,
                        'instruction': instructionGiven.text,
                        'hasInstruction': true,
                      };
                      docTickets.update(queueData);
                      final docService = FirebaseFirestore.instance
                          .collection('Business Services')
                          .doc(widget.serviceId);
                      print("serving number $servingNumber");
                      final serviceData = {
                        'serving': (servingNumber + 1).toString(),
                      };
                      docService.update(serviceData);
                      reset();
                      startTimer();
                    } else {
                      final docTickets = FirebaseFirestore.instance
                          .collection('Queue Tickets')
                          .doc(currentQueueId);

                      final queueData = {
                        'servingDuration': savedDuration,
                        'waitingDuration': diffennceString,
                        'isDone': true,
                        'instruction': instructionGiven.text,
                        'hasInstruction': true,
                      };
                      docTickets.update(queueData);
                      reset();
                      startTimer();
                    }
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xff294243),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ))
            ],
          ));
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
                element['accountID'].toString().contains(currentUserId))
            .map((doc) => Users.fromJson(doc.data()))
            .toList());
  }

  Stream<List<Queue>> readQueue() {
    return FirebaseFirestore.instance
        .collection('Queue Tickets')
        .orderBy("queueNumber", descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['serviceId'].toString().contains(widget.serviceId))
            .map((doc) => Queue.fromJson(doc.data()))
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
}
