// ignore_for_file: file_names, avoid_print, prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:qnywhere/model/userNotifications.dart';

class UserNotificationPage extends StatefulWidget {
  const UserNotificationPage({Key? key}) : super(key: key);

  @override
  State<UserNotificationPage> createState() => _UserNotificationPageState();
}

class _UserNotificationPageState extends State<UserNotificationPage> {
  final User users = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
              Color(0xff398E7F),
              Color(0xff294243),
            ]))),
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      
      ),
      body: StreamBuilder<List<UserNotifications>>(
          stream: readNotifications(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Text('Something Went Wrong ${snapshot.error}');
            } else if (snapshot.hasData) {
              final userNotifs = snapshot.data!;
              return ListView.builder(
                itemCount: userNotifs.length,
                itemBuilder: (context, index) {
                  final notifications = userNotifs[index];

                  return Slidable(
                      endActionPane: ActionPane(
                        motion: BehindMotion(),
                        children: [
                          SlidableAction(
                            backgroundColor: Colors.red,
                            icon: Icons.delete,
                            label: 'Delete',
                            onPressed: ((context) {
                              FirebaseFirestore.instance
                                  .collection("User Notifications")
                                  .doc(userNotifs[index].notificationId)
                                  .delete()
                                  .then(
                                    (doc) => print("Document deleted"),
                                    onError: (e) =>
                                        print("Error updating document $e"),
                                  );
                            }),
                          )
                        ],
                      ),
                      child: buildNotifListView(notifications));
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Widget buildNotifListView(UserNotifications notifications) => Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        shadowColor: Colors.black,
        child: ListTile(
          title: Text(
            "${notifications.businessName} - ${notifications.serviceName}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: (notifications.hasIntruction == false)
              ? Text(
                  notifications.text,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Text(
                  notifications.instruction,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      );

  Stream<List<UserNotifications>> readNotifications() {
    return FirebaseFirestore.instance
        .collection('User Notifications')
        .orderBy("dateCreated", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['userId'].toString().contains(users.uid))
            .map((doc) => UserNotifications.fromJson(doc.data()))
            .toList());
  }
}
