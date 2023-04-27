import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qnywhere/model/queue.dart';
import 'package:qnywhere/model/service.dart';
import 'package:qnywhere/model/user.dart';
import 'package:qnywhere/owner/ownerHomepage.dart';
import 'package:qnywhere/owner/ownerPage.dart';
import 'package:qnywhere/owner/ownerQueuePage.dart';

class ContinueQueuePage extends StatefulWidget {
  final String serviceId;
  final String buisnessid;
  final String serviceName;

  const ContinueQueuePage(
      {Key? key,
      required this.serviceId,
      required this.buisnessid,
      required this.serviceName})
      : super(key: key);

  @override
  State<ContinueQueuePage> createState() => _ContinueQueuePageState();
}

class _ContinueQueuePageState extends State<ContinueQueuePage> {
  final User user = FirebaseAuth.instance.currentUser!;
  String userAccountId = "";
  int servingNumber = 0;
  int queueLength = 0;
  String currentUserId = "";
  String businessId = "";
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: const Color(0xff398E7F),
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xff294243),
            title: const Padding(
              padding: EdgeInsets.only(left: 50),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 100),
                  child: Text("Live Queue",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
                ),
              ),
            ),
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ))),
        body: SafeArea(
          child: StreamBuilder<List<Queue>>(
              stream: readQueue(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something Went Wrong');
                } else if (snapshot.hasData) {
                  final listQueue = snapshot.data!;
                  queueLength = listQueue.length;

                  if (listQueue.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            height: MediaQuery.of(context).size.height * 0.50,
                            width: MediaQuery.of(context).size.width,
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(40.0),
                                  bottomRight: Radius.circular(40.0),
                                )),
                            child: ListView(
                                children:
                                    listQueue.map(buildServices).toList())),
                        Container(
                            height: MediaQuery.of(context).size.height * 0.38,
                            width: MediaQuery.of(context).size.width,
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                  Color(0xff294243),
                                  Color(0xff398E7F),
                                ])),
                            child: StreamBuilder<List<Service>>(
                              stream: readService(),
                              builder: ((context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text(
                                      'Something Went Wrong - service: ${snapshot.error}');
                                } else if (snapshot.hasData) {
                                  final currentService = snapshot.data!;
                                  servingNumber =
                                      int.parse(currentService.first.serving);

                                  if (servingNumber <= listQueue.length) {
                                    currentUserId =
                                        listQueue[servingNumber - 1].accountId;
                                  } else {
                                    currentUserId =
                                        listQueue[servingNumber - 2].accountId;
                                  }

                                  return StreamBuilder<List<Users>>(
                                    stream: readSpecificUser(),
                                    builder: ((context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Text(
                                            'Something Went Wrong - User: ${snapshot.error}');
                                      } else if (snapshot.hasData) {
                                        final userDetails = snapshot.data!;

                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                continueService(size),
                                                const SizedBox(height: 10),
                                                endService(size)
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const SizedBox(height: 10),
                                                const Text("CURRENT",
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const SizedBox(height: 10),
                                                (servingNumber <=
                                                        listQueue.length)
                                                    ? Text(
                                                        (int.parse(currentService
                                                                    .first
                                                                    .serving) <
                                                                10)
                                                            ? "0${listQueue[int.parse(currentService.first.serving) - 1].queueNumber}"
                                                            : currentService
                                                                .first.serving,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 65,
                                                            color:
                                                                Colors.white),
                                                      )
                                                    : Text(
                                                        (int.parse(currentService
                                                                    .first
                                                                    .serving) <
                                                                10)
                                                            ? "0${(listQueue[int.parse(currentService.first.serving) - 2].queueNumber) + 1}"
                                                            : currentService
                                                                .first.serving,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 65,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                const SizedBox(height: 5),
                                                (servingNumber <=
                                                        listQueue.length)
                                                    ? Text(
                                                        "${userDetails.first.accountFirstName} ${userDetails.first.accountLastName}",
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal))
                                                    : Text(
                                                        "Waiting for the\n next customer",
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal)),
                                                const SizedBox(height: 5),
                                                (servingNumber <
                                                        listQueue.length)
                                                    ? Text(
                                                        userDetails.first
                                                            .accountPhoneNumber,
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal))
                                                    : SizedBox.shrink(),
                                                const SizedBox(height: 15),
                                              ],
                                            ),
                                          ],
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
                            ))
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.50,
                            width: MediaQuery.of(context).size.width,
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(40.0),
                                  bottomRight: Radius.circular(40.0),
                                )),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "No queues as of the moment",
                                  style: TextStyle(
                                      color: Color(0xff8D8D8D),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.circle,
                                        size: 18, color: Color(0xff8D8D8D)),
                                    SizedBox(width: 5),
                                    Icon(Icons.circle,
                                        size: 18, color: Color(0xff8D8D8D)),
                                    SizedBox(width: 5),
                                    Icon(Icons.circle,
                                        size: 18, color: Color(0xff8D8D8D))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.38,
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                Color(0xff294243),
                                Color(0xff398E7F),
                              ])),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 50),
                                child: Center(child: endService(size)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 50),
                                child: Center(child: returnHome(size)),
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ));
  }

  InkWell continueService(Size size) {
    return InkWell(
      onTap: (() {
        final docTickets = FirebaseFirestore.instance
            .collection('Business Services')
            .doc(widget.serviceId);

        final queueData = {
          'inService': true,
        };
        docTickets.update(queueData);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => OwnerQueuePage(
                  serviceId: widget.serviceId,
                  businessId: widget.buisnessid,
                  serviceName: widget.serviceName,
                )));
      }),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: size.width * 0.45,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color(0xff294243),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        child: const Text(
          'View Service',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildServices(Queue queue) {
    userAccountId = queue.accountId;
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 5),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff398E7F),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                (queue.queueNumber < 10)
                    ? "0${queue.queueNumber}"
                    : queue.queueNumber.toString(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: Colors.white),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(queue.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      )),
                  Text(queue.mobileNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  InkWell endService(Size size) {
    double waitingTime = 0.0;
    double servingTime = 0.0;
    int counter = 0;
    return InkWell(
      onTap: (() async {
        final allTickets = await FirebaseFirestore.instance
            .collection('Queue Tickets')
            .where('serviceId', isEqualTo: widget.serviceId)
            .get();

        for (var doc in allTickets.docs) {
          Map<String, dynamic> data = doc.data();
          String queueId = data['queueId'];
          businessId = data['businessId'];
          String waitingDuration = data['waitingDuration'];
          String servingDuration = data['servingDuration'];
          String fullName = data['fullName'];
          bool isDone = data['isDone'];
          bool isCancel = data['isCancel'];
          Timestamp timeQueued = data['timeQueued'];
          String serviceName = data['serviceName'];
          if (isDone == true && isCancel == false) {
            counter++;
            waitingTime = waitingTime + double.parse(waitingDuration);
            servingTime = servingTime + double.parse(servingDuration);
            final businessAcc = await FirebaseFirestore.instance
                .collection('Business Accounts')
                .where('ownerId', isEqualTo: user.uid)
                .get();

            for (var doc in businessAcc.docs) {
              Map<String, dynamic> data = doc.data();
              List<dynamic> businessHistory = data['businessHistory'];
              final docBusiness = FirebaseFirestore.instance
                  .collection('Business Accounts')
                  .doc(businessId);
              businessHistory.add({
                "queueId": queueId,
                "businessId": businessId,
                "fullName": fullName,
                "serviceName": serviceName,
                "waitingDuration": waitingDuration,
                "servingDuration": servingDuration,
                "timeQueued": timeQueued,
              });
              final docBusinessData = {'businessHistory': businessHistory};
              docBusiness.update(docBusinessData);
            }
          }
          FirebaseFirestore.instance
              .collection("Queue Tickets")
              .doc(queueId)
              .delete()
              .then(
                (doc) => print("Document deleted"),
                onError: (e) => print("Error updating document $e"),
              );
        }
        waitingTime = waitingTime / counter;
        servingTime = servingTime / counter;

        final docService = FirebaseFirestore.instance
            .collection('Business Services')
            .doc(widget.serviceId);

        final serviceData = {
          'serving': "1",
          'inService': false,
          'waitingTime': waitingTime.toString(),
          'servingTime': servingTime.toString()
        };
        docService.update(serviceData);
      }),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: size.width * 0.45,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color.fromARGB(255, 0, 33, 59),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        child: const Text(
          'End Service',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  InkWell returnHome(Size size) {
    return InkWell(
      onTap: (() {
        Navigator.of(context).pop();
      }),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: size.width * 0.45,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color.fromARGB(255, 0, 33, 59),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        child: const Text(
          'Return',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Stream<List<Queue>> readQueue() {
    return FirebaseFirestore.instance
        .collection('Queue Tickets')
        .orderBy("queueNumber", descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['serviceId'].toString().contains(widget.serviceId))
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['isRemoved'].toString().contains("false"))
            .map((doc) => Queue.fromJson(doc.data()))
            .toList());
  }

  Stream<List<Users>> readUser() {
    return FirebaseFirestore.instance
        .collection('User Accounts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['accountID'].toString().contains(userAccountId))
            .map((doc) => Users.fromJson(doc.data()))
            .toList());
  }

  Stream<List<Users>> readSpecificUser() {
    return FirebaseFirestore.instance
        .collection('User Accounts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['accountID'].toString().contains(currentUserId))
            .map((doc) => Users.fromJson(doc.data()))
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
