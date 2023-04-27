// ignore_for_file: file_names, avoid_print

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qnywhere/components/queueNotification.dart';
import 'package:qnywhere/model/business.dart';
import 'package:qnywhere/model/user.dart';
import 'package:qnywhere/user/userBusinessCategory.dart';
import 'package:qnywhere/user/userQueueTicket.dart';
import 'package:qnywhere/user/viewBusinessPage.dart';
import 'package:qnywhere/utilities/search_widget.dart';
import 'package:uuid/uuid.dart';

class UserHomePageScreen extends StatefulWidget {
  const UserHomePageScreen({Key? key}) : super(key: key);

  @override
  State<UserHomePageScreen> createState() => _UserHomePageScreenState();
}

class _UserHomePageScreenState extends State<UserHomePageScreen> {
  final User users = FirebaseAuth.instance.currentUser!;
  String fetchQueueId = "";
  String fetchBusinessId = "";
  String fetchServiceId = "";
  String recentBusiness = "";
  String userFullName = "";
  String cancelServiceName = "";
  String cancelBusinessName = "";
  String query = '';
  var uuid = const Uuid();
  String _uid = "";
  late Timer mytimer;
  late List<Business> business;
  late List<Business> filteredBusiness;
  List category = [
    "Pharmacy",
    "School",
    "Bank",
    "Clinic",
    "Restaurant",
    "Store"
  ];
  static const _iconTypes = <IconData>[
    FontAwesomeIcons.prescription,
    FontAwesomeIcons.school,
    FontAwesomeIcons.buildingColumns,
    FontAwesomeIcons.houseChimneyMedical,
    FontAwesomeIcons.utensils,
    FontAwesomeIcons.store
  ];

  void listenNotification() =>
      QueueNotification.onNotifications.stream.listen(onClickedNotification);
  void onClickedNotification(String? payload) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => QueueTicketPage(
              queueId: fetchQueueId,
              businessId: fetchBusinessId,
              serviceId: fetchServiceId,
            )));
  }

  void checkQueue() async {
    final uploadTime = DateTime.now();
    Timestamp myTimeStamp = Timestamp.fromDate(uploadTime);
    final queueTickets = await FirebaseFirestore.instance
        .collection('Queue Tickets')
        .where('accountId', isEqualTo: users.uid)
        .where("isDone", isEqualTo: false)
        .where("isRemoved", isEqualTo: false)
        .get();

    if (queueTickets.docs.isNotEmpty) {
      var collection = FirebaseFirestore.instance.collection('User Accounts');
      collection
          .doc(users.uid)
          .update({'inQueue': true}) // <-- Updated data
          .then((_) => print('Success'))
          .catchError((error) => print('Failed: $error'));

      for (var doc in queueTickets.docs) {
        Map<String, dynamic> data = doc.data();
        int queueNumber = data['queueNumber'];
        String queueId = data['queueId'];
        String serviceId = data['serviceId'];
        String businessId = data['businessId'];
        bool notiyfNextInLine = data['notiyfNextInLine'];
        bool notiyfTurnComingUp = data['notiyfTurnComingUp'];
        fetchQueueId = queueId;
        fetchServiceId = serviceId;
        fetchBusinessId = fetchBusinessId;

        final queuedServices = await FirebaseFirestore.instance
            .collection('Business Services')
            .where('businessId', isEqualTo: businessId)
            .where("serviceId", isEqualTo: serviceId)
            .get();

        for (var doc in queuedServices.docs) {
          Map<String, dynamic> data = doc.data();
          String serving = data['serving'];
          String businessName = data['businessName'];
          String serviceName = data['serviceName'];

          String waitingTime = data['waitingTime'];
          double estimatedWaitingTime = double.parse(waitingTime) * 2;
          int firstAlertNotification = queueNumber - 3;
          int secondAlertNotification = queueNumber - 1;

          if (queueNumber > 1) {
            if (secondAlertNotification < int.parse(serving)) {
              if (queueNumber > 2) {
                if (notiyfNextInLine == false) {
                  _uid = uuid.v4();
                  final docNotify = FirebaseFirestore.instance
                      .collection('User Notifications')
                      .doc(_uid);
                  final docNotifyData = {
                    'notificationId': _uid,
                    'userId': users.uid,
                    'businessName': businessName,
                    'text':
                        "Hi User!, i would like to inform that you that its your turn in the ${serviceName} from ${businessName}, please proceed to the location to avoid cancellation",
                    'dateCreated': myTimeStamp,
                    'serviceName': serviceName,
                    'instruction': "",
                    'hasIntruction': false,
                  };

                  docNotify.set(docNotifyData);

                  QueueNotification.showNotification(
                      title:
                          'It\'s Your Turn, Please Proceed to the $serviceName',
                      body:
                          // ignore: unnecessary_brace_in_string_interps
                          'Hi User!, i would like to inform that you that its your turn in the ${serviceName} from ${businessName}, please proceed to the location to avoid cancellation',
                      payload: 'next.warning');

                  final docTicket = FirebaseFirestore.instance
                      .collection('Queue Tickets')
                      .doc(queueId);

                  final ticketData = {
                    'notiyfNextInLine': true,
                  };

                  docTicket.update(ticketData);
                }
              }
            } else if (firstAlertNotification < int.parse(serving)) {
              if (notiyfTurnComingUp == false) {
                _uid = uuid.v4();
                final docNotify = FirebaseFirestore.instance
                    .collection('User Notifications')
                    .doc(_uid);
                final docNotifyData = {
                  'notificationId': _uid,
                  'userId': users.uid,
                  'businessName': businessName,
                  'text':
                      "Hi User!, i would like to inform that there are only 2 person left before your turn, please proceed to the location immediately",
                  'dateCreated': myTimeStamp,
                  'serviceName': serviceName,
                  'instruction': "",
                  'hasIntruction': false,
                };

                docNotify.set(docNotifyData);

                QueueNotification.showNotification(
                    title: 'YOUR TURN IS COMING UP',
                    body:
                        // ignore: unnecessary_brace_in_string_interps
                        'Hi User!, i would like to inform that your queue in the ${serviceName} from ${businessName} is coming up please proceed to the location immediately',
                    payload: 'turn.warning');

                final docTicket = FirebaseFirestore.instance
                    .collection('Queue Tickets')
                    .doc(queueId);

                final ticketData = {
                  'notiyfTurnComingUp': true,
                };

                docTicket.update(ticketData);
              }
            }
          }
        }
      }
    } else {
      var collection = FirebaseFirestore.instance.collection('User Accounts');
      collection
          .doc(users.uid)
          .update({'inQueue': false}) // <-- Updated data
          .then((_) => print('Success No Current Queue'))
          .catchError((error) => print('Failed: $error'));

      final cancelTickets = await FirebaseFirestore.instance
          .collection('Queue Tickets')
          .where('accountId', isEqualTo: users.uid)
          .where("isDone", isEqualTo: true)
          .where("isCancel", isEqualTo: true)
          .where("isNotifiedCancelled", isEqualTo: false)
          .get();

      if (cancelTickets.docs.isNotEmpty) {
        for (var doc in cancelTickets.docs) {
          Map<String, dynamic> data = doc.data();
          String queueId = data['queueId'];
          String fullName = data['fullName'];
          bool notifyCancellQueue = data['isNotifiedCancelled'];
          String serviceName = data['serviceName'];
          String businessId = data['businessId'];
          userFullName = fullName;
          cancelServiceName = serviceName;

          final businessAccounts = await FirebaseFirestore.instance
              .collection('Business Accounts')
              .where('businessId', isEqualTo: businessId)
              .get();

          if (businessAccounts.docs.isNotEmpty) {
            if (notifyCancellQueue == false) {
              print("cancelled ticket");
              for (var doc in businessAccounts.docs) {
                Map<String, dynamic> data = doc.data();
                String businessName = data['businessName'];
                cancelBusinessName = businessName;

                QueueNotification.showNotification(
                    title: 'YOUR QUEUE HAS BEEN CANCELLED',
                    body:
                        // ignore: unnecessary_brace_in_string_interps
                        'Hi User!, i would like to inform that your queue in the ${serviceName} from ${businessName} is next in line please proceed to the location to avoid cancellation',
                    payload: 'next.warning');

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

                final docTicket = FirebaseFirestore.instance
                    .collection('Queue Tickets')
                    .doc(queueId);

                final ticketData = {
                  'isNotifiedCancelled': true,
                };

                docTicket.update(ticketData);

                _uid = uuid.v4();
                final docNotify = FirebaseFirestore.instance
                    .collection('User Notifications')
                    .doc(_uid);
                final docNotifyData = {
                  'notificationId': _uid,
                  'userId': users.uid,
                  'businessName': businessName,
                  'text':
                      "Your queue was cancelled. Sorry for the inconvenience",
                  'dateCreated': myTimeStamp,
                  'serviceName': serviceName,
                  'instruction': "",
                  'hasIntruction': false,
                };

                docNotify.set(docNotifyData);
              }
            }
          }
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
      backgroundColor: const Color(0xff398E7F),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
              Color(0xff398E7F),
              Color(0xff294243),
            ]))),
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 15),
          child: Text(
            "Categories",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.0),
              topRight: Radius.circular(40.0),
            )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSearch(),
            const Padding(
                padding: EdgeInsets.only(left: 30, top: 10, bottom: 15),
                child: Text("Select a Category",
                    style: TextStyle(
                        color: Color(0xff294243),
                        fontWeight: FontWeight.bold,
                        fontSize: 24))),
            SizedBox(
              height: 100,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: category.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, i) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => BusinessCategoryScreen(
                                category: category[i],
                              )));
                    },
                    child: SizedBox(
                      width: 150,
                      child: Card(
                          elevation: 5,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(_iconTypes[i],
                                  color: const Color(0xff294243), size: 30),
                              Text(
                                category[i],
                                style: const TextStyle(
                                    color: Color(0xff294243),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          )),
                    ),
                  );
                },
              ),
            ),
            const Padding(
                padding: EdgeInsets.only(left: 30, top: 20),
                child: Text("Recents",
                    style: TextStyle(
                        color: Color(0xff294243),
                        fontWeight: FontWeight.bold,
                        fontSize: 26))),
            StreamBuilder<List<Users>>(
                stream: readUser(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something Went Wrong ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final user = snapshot.data!;
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.38,
                      child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 10),
                          children:
                              user.first.recents.map(buildRecents).toList()),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }

  Widget buildRecents(Recents recents) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: MediaQuery.of(context).size.width * 0.55,
            decoration: const BoxDecoration(
                color: Color(0xff294243),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, left: 15, right: 15, bottom: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(recents.businessImageUrl,
                        width: 200, height: 150, fit: BoxFit.fill),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 5, left: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: Text(recents.businessName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: GestureDetector(
                          onTap: (() {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ViewBusinessPage(
                                      businessId: recents.businessId,
                                    )));
                          }),
                          child: Container(
                            width: 35,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      recents.businessLocation,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    )
                  ],
                )
              ],
            )),
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
                "Your queue was cancelled.",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "hi $userFullName, we regret to inform you that your queue in the $cancelServiceName at $cancelBusinessName was cancelled",
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
                child: Image.asset("assets/images/cancelledQueue.png")),
          ),
        ),
      ],
    );
  }

  Stream<List<Users>> readUser() {
    return FirebaseFirestore.instance
        .collection('User Accounts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['accountID'].toString().contains(users.uid))
            .map((doc) => Users.fromJson(doc.data()))
            .toList());
  }

  void searchBusiness(String query) {
    final business = filteredBusiness.where((business) {
      final nameLower = business.businessName.toLowerCase();
      final searchLower = query.toLowerCase();

      return nameLower.contains(searchLower);
    }).toList();

    setState(() {
      this.query = query;
      this.business = business;
    });
  }

  Widget buildSearch() => SearchWidget(
        text: query,
        hintText: 'Search',
        onChanged: searchBusiness,
      );
}
