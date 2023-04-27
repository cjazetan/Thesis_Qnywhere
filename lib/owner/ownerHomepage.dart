// ignore_for_file: file_names, avoid_print

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:qnywhere/components/queueNotification.dart';
import 'package:qnywhere/model/business.dart';
import 'package:qnywhere/model/service.dart';
import 'package:qnywhere/owner/editBusiness.dart';
import 'package:qnywhere/owner/ownerCheckQueuePage.dart';
import 'package:qnywhere/owner/ownerPreQueuePage.dart';
import 'package:qnywhere/owner/ownerStatistics.dart';
import 'package:uuid/uuid.dart';

class OwnerHomepageScreen extends StatefulWidget {
  const OwnerHomepageScreen({Key? key}) : super(key: key);

  @override
  State<OwnerHomepageScreen> createState() => _OwnerHomepageScreenState();
}

class _OwnerHomepageScreenState extends State<OwnerHomepageScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  TextEditingController service = TextEditingController();
  int index = 1;
  String businessName = "";
  String businessId = "";
  String serviceId = "";
  String serviceName = "";
  var uuid = const Uuid();
  String _uid = "";
  late Timer mytimer;

  void listenNotification() =>
      QueueNotification.onNotifications.stream.listen(onClickedNotification);
  void onClickedNotification(String? payload) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CheckQueuePage(
            buisnessid: businessId,
            serviceId: serviceId,
            serviceName: serviceName)));
  }

  void checkQueue() async {
    final businessAccount = await FirebaseFirestore.instance
        .collection('Business Accounts')
        .where('ownerId', isEqualTo: user.uid)
        .get();

    if (businessAccount.docs.isNotEmpty) {
      for (var doc in businessAccount.docs) {
        Map<String, dynamic> data = doc.data();
        String businessId = data['businessId'];
        final queueTickets = await FirebaseFirestore.instance
            .collection('Queue Tickets')
            .where('businessId', isEqualTo: businessId)
            .where("isCancelCustomer", isEqualTo: true)
            .where("isNotifiedCancelled", isEqualTo: false)
            .get();

        if (queueTickets.docs.isNotEmpty) {
          for (var doc in queueTickets.docs) {
            Map<String, dynamic> data = doc.data();
            String queueId = data['queueId'];
            String fullName = data['fullName'];
            String serviceName = data['serviceName'];
            int queueNumber = data['queueNumber'];

            QueueNotification.showNotification(
                title: 'A CUSTOMER HAS CANCELLED HIS/HER QUEUE',
                body:
                    // ignore: unnecessary_brace_in_string_interps
                    'Hi User!, i would like to inform that queue number ${queueNumber}, ${fullName} has cancelled his/her queue in  ${serviceName} service',
                payload: 'next.warning');

            final docTicket = FirebaseFirestore.instance
                .collection('Queue Tickets')
                .doc(queueId);

            final ticketData = {
              'isNotifiedCancelled': true,
            };

            docTicket.update(ticketData);
          }
        }
      }
    }
  }

  DateTime findFirstDateOfPreviousWeek(DateTime dateTime) {
    final DateTime sameWeekDayOfLastWeek =
        dateTime.subtract(const Duration(days: 7));
    return findFirstDateOfTheWeek(sameWeekDayOfLastWeek);
  }

  DateTime findFirstDateOfTheWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 1));
  }

  DateTime findLastDateOfTheWeek(DateTime dateTime) {
    return dateTime
        .add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
  }

  DateTime findLastDateOfPreviousWeek(DateTime dateTime) {
    final DateTime sameWeekDayOfLastWeek =
        dateTime.subtract(const Duration(days: 7));
    return findLastDateOfTheWeek(sameWeekDayOfLastWeek);
  }

  void checkDate() async {
    final businessAccount = await FirebaseFirestore.instance
        .collection('Business Accounts')
        .where('ownerId', isEqualTo: user.uid)
        .get();
    if (businessAccount.docs.isNotEmpty) {
      for (var doc in businessAccount.docs) {
        Map<String, dynamic> data = doc.data();
        Timestamp dateRecorded = data['dateRecorded'];
        String businessId = data['businessId'];
        List<dynamic> dailyServingTime = data['dailyServingTime'];
        List<dynamic> dailyWaitingTime = data['dailyWaitingTime'];
        List<dynamic> weeklyServingTime = data['weeklyServingTime'];
        List<dynamic> weeklyWaitingTime = data['weeklyWaitingTime'];
        List<dynamic> dailyLogs = data['dailyLogs'];
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        DateTime today = DateTime.now();
        DateTime dayRecorded = dateRecorded.toDate();
        final String todayFormatted = formatter.format(today);
        final String dayRecordedFormatted = formatter.format(dayRecorded);
        print(todayFormatted);
        print(dayRecordedFormatted);
        if (todayFormatted != dayRecordedFormatted) {
          final businessService = await FirebaseFirestore.instance
              .collection('Business Services')
              .where('ownerId', isEqualTo: user.uid)
              .where('businessId', isEqualTo: businessId)
              .get();
          if (businessService.docs.isNotEmpty) {
            int counterDay = 0;
            int totalCount = 0;
            double totalWaitingTimeDay = 0.0;
            double totalServingTimeDay = 0.0;
            for (var doc in businessService.docs) {
              Map<String, dynamic> data = doc.data();
              String servingTime = data['servingTime'];
              String waitingTime = data['waitingTime'];
              String serving = data['serving'];
              totalCount = totalCount + int.parse(serving);
              totalWaitingTimeDay =
                  totalWaitingTimeDay + double.parse(waitingTime);
              totalServingTimeDay =
                  totalServingTimeDay + double.parse(servingTime);
              counterDay++;
            }
            totalWaitingTimeDay = totalWaitingTimeDay / counterDay;
            totalServingTimeDay = totalServingTimeDay / counterDay;
            String time = "time";
            String logs = "logs";
            String dateRecorded = "dateRecorded";
            DateTime currenDate = DateTime.now();
            dailyServingTime.add({
              dateRecorded: Timestamp.fromDate(currenDate),
              time: totalServingTimeDay.toString()
            });
            dailyWaitingTime.add({
              dateRecorded: Timestamp.fromDate(currenDate),
              time: totalWaitingTimeDay.toString()
            });
            dailyLogs.add({
              dateRecorded: Timestamp.fromDate(currenDate),
              logs: totalCount
            });
            int servingCounter = 0;
            double totalServing = 0.0;
            for (var i = 0; i < dailyServingTime.length; i++) {
              totalServing =
                  totalServing + double.parse(dailyServingTime[i][time]);
              servingCounter++;
            }
            double avgServing = totalServing / servingCounter;
            print(avgServing);
            int waitingCounter = 0;
            double totalWaiting = 0.0;
            for (var i = 0; i < dailyWaitingTime.length; i++) {
              totalWaiting =
                  totalWaiting + double.parse(dailyWaitingTime[i][time]);
              waitingCounter++;
            }
            double avgWaiting = totalWaiting / waitingCounter;
            print(avgWaiting);
            final docBusiness = FirebaseFirestore.instance
                .collection('Business Accounts')
                .doc(businessId);
            print(dailyServingTime.length);
            final businessData = {
              'dailyServingTime': dailyServingTime,
              'dailyWaitingTime': dailyWaitingTime,
              'dailyLogs': dailyLogs,
              'dailyAvgServingTime': avgServing.toString(),
              'dailyAvgWaitingTime': avgWaiting.toString(),
              'dateRecorded': Timestamp.fromDate(today)
            };

            docBusiness.update(businessData);
          }
        }
      }
    } else {
      print("Same Date");
    }
  }

  void checkEndOfWeek() async {
    final businessAccount = await FirebaseFirestore.instance
        .collection('Business Accounts')
        .where('ownerId', isEqualTo: user.uid)
        .get();
    if (businessAccount.docs.isNotEmpty) {
      for (var doc in businessAccount.docs) {
        Map<String, dynamic> data = doc.data();
        String businessId = data['businessId'];
        List<dynamic> dailyServingTime = data['dailyServingTime'];
        List<dynamic> dailyWaitingTime = data['dailyWaitingTime'];
        List<dynamic> weeklyServingTime = data['weeklyServingTime'];
        List<dynamic> weeklyWaitingTime = data['weeklyWaitingTime'];
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        DateTime currentDate = DateTime.now();
        final String todayFormatted = formatter.format(currentDate);
        DateTime today = DateTime.parse(todayFormatted);
        DateTime firstDayOfPreviousWeek = findFirstDateOfPreviousWeek(today);
        DateTime lastDayOfPreviousWeek = findLastDateOfPreviousWeek(today);
        final String lastDayOfWeekFormatted =
            formatter.format(lastDayOfPreviousWeek.add(Duration(days: 1)));
        print(todayFormatted);
        print(lastDayOfWeekFormatted);
        if (todayFormatted == lastDayOfWeekFormatted) {
          int counterWaitingWeek = 0;
          int counterServingWeek = 0;
          double totalWaitingTimeWeek = 0.0;
          double totalServingTimeWeek = 0.0;
          for (int i = 0; i < dailyServingTime.length; i++) {
            if (dailyServingTime[i]["dateRecorded"]
                        .compareTo(Timestamp.fromDate(firstDayOfPreviousWeek)) >
                    0 &&
                dailyServingTime[i]["dateRecorded"].compareTo(
                        Timestamp.fromDate(
                            lastDayOfPreviousWeek.add(Duration(days: 1)))) <
                    0) {
              totalServingTimeWeek = totalServingTimeWeek +
                  double.parse(dailyServingTime[i]["time"]);
              counterServingWeek++;
            }
          }
          for (int i = 0; i < dailyWaitingTime.length; i++) {
            if (dailyWaitingTime[i]["dateRecorded"]
                        .compareTo(Timestamp.fromDate(firstDayOfPreviousWeek)) >
                    0 ||
                dailyWaitingTime[i]["dateRecorded"].compareTo(
                        Timestamp.fromDate(
                            lastDayOfPreviousWeek.add(Duration(days: 1)))) <
                    0) {
              totalWaitingTimeWeek = totalWaitingTimeWeek +
                  double.parse(dailyWaitingTime[i]["time"]);
              counterWaitingWeek++;
            }
          }
          String time = "time";
          String dateRecorded = "dateRecorded";
          totalServingTimeWeek = totalServingTimeWeek / counterServingWeek;
          totalWaitingTimeWeek = totalWaitingTimeWeek / counterWaitingWeek;
          weeklyServingTime.add({
            dateRecorded: Timestamp.fromDate(currentDate),
            time: totalServingTimeWeek.toString()
          });
          weeklyWaitingTime.add({
            dateRecorded: Timestamp.fromDate(currentDate),
            time: totalWaitingTimeWeek.toString()
          });

          int servingCounter = 0;
          double totalServing = 0.0;
          for (var i = 0; i < weeklyServingTime.length; i++) {
            totalServing =
                totalServing + double.parse(weeklyServingTime[i][time]);
            servingCounter++;
          }
          double avgServing = totalServing / servingCounter;

          int waitingCounter = 0;
          double totalWaiting = 0.0;
          for (var i = 0; i < weeklyWaitingTime.length; i++) {
            totalWaiting =
                totalWaiting + double.parse(weeklyWaitingTime[i][time]);
            waitingCounter++;
          }
          double avgWaiting = totalWaiting / waitingCounter;

          final docBusiness = FirebaseFirestore.instance
              .collection('Business Accounts')
              .doc(businessId);
          print(dailyServingTime.length);
          final businessData = {
            'weeklyServingTime': weeklyServingTime,
            'weeklyWaitingTime': weeklyWaitingTime,
            'weeklyAvgServingTime': avgServing.toString(),
            'weeklyAvgWaitingTime': avgWaiting.toString(),
          };

          docBusiness.update(businessData);
        }
      }
    }
  }

  @override
  void initState() {
    QueueNotification.init();
    listenNotification();
    mytimer = Timer.periodic(Duration(seconds: 5), (timer) {
      print("checking queue");
      checkQueue();
    });
    checkDate();
    checkEndOfWeek();
    super.initState();
  }

  @override
  void dispose() {
    mytimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Color(0xff398E7F)),
        ),
        elevation: 0,
        foregroundColor: Colors.white,
       
        actions: [
          GestureDetector(
              onTap: (() {
                   Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const BusinessStatistics()));
              }),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                child: Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xff294243),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: const Center(
                      child: Text(
                    'Check Statistic',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  )),
                ),
              ))
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Color(0xff398E7F),
                  Color(0xff294243),
                ])),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<List<Business>>(
                      stream: readBusiness(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          return Center(
                            child:
                                Text('Something Went Wrong: ${snapshot.error}'),
                          );
                        } else if (snapshot.hasData) {
                          final business = snapshot.data!;
                          businessName = business.first.businessName;
                          businessId = business.first.businessId;
                          return Container(
                              height: MediaQuery.of(context).size.height * 0.40,
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(153, 240, 240, 240),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20,
                                        left: 10,
                                        right: 15,
                                        bottom: 5),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                          business.first.businessImageUrl,
                                          width: 325,
                                          height: 200,
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 52, top: 10, bottom: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(business.first.businessName,
                                            style: const TextStyle(
                                                color: Color(0xff294243),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17)),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 30),
                                          child: GestureDetector(
                                            onTap: (() {
                                              Navigator.of(context).pushReplacement(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const EditBusiness()));
                                            }),
                                            child: Container(
                                              width: 50,
                                              decoration: BoxDecoration(
                                                color: const Color(0xff398E7F),
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              child: const Center(
                                                  child: Text(
                                                'Edit',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              )),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 47),
                                        child: Icon(Icons.location_on,
                                            size: 18, color: Color(0xff294243)),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        business.first.businessLocation,
                                        style: const TextStyle(
                                            color: Color(0xff294243),
                                            fontSize: 14),
                                      )
                                    ],
                                  )
                                ],
                              ));
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.32,
                    child: StreamBuilder<List<Service>>(
                        stream: readService(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return Center(
                              child: Text(
                                  'Something Went Wrong: ${snapshot.error}'),
                            );
                          } else if (snapshot.hasData) {
                            final services = snapshot.data!;
                            if (services.isNotEmpty) {
                              return ListView(
                                  children:
                                      services.map(buildServices).toList());
                            } else {
                              return Container();
                            }
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        }),
                  )
                ],
              ),
            ),
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: openDialog,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Container(
                    width: 160,
                    height: 50,
                    decoration: const BoxDecoration(
                        color: Color(0xff398E7F),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(
                            Icons.add_circle,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        Text('Add Service',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Future openDialog() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            backgroundColor: const Color(0xff398E7F),
            title: const Text(
              'Type of Service',
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
                controller: service,
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
                    _uid = uuid.v4();
                    try {
                      final docService = FirebaseFirestore.instance
                          .collection('Business Services')
                          .doc(_uid);

                      final data = {
                        'serviceId': _uid,
                        'serviceName': service.text,
                        'ownerId': user.uid,
                        'inService': false,
                        'businessName': businessName,
                        'businessId': businessId,
                        'serving': "1",
                        'servingTime': "180",
                        'waitingTime': "180",
                      };
                      docService.set(data);
                    } catch (e) {
                      print(e);
                    }
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
  Widget buildServices(Service service) => Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 15),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: const Color(0xff497972),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15))),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CheckQueuePage(
                    buisnessid: service.businessId,
                    serviceId: service.serviceId,
                    serviceName: service.serviceName)));
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  service.serviceName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                )),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                )
              ],
            ),
          ),
        ),
      );
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

  Stream<List<Service>> readService() {
    return FirebaseFirestore.instance
        .collection('Business Services')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['ownerId'].toString().contains(user.uid))
            .map((doc) => Service.fromJson(doc.data()))
            .toList());
  }
}
