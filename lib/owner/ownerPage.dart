// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:qnywhere/owner/ownerHomepage.dart';
import 'package:qnywhere/owner/ownerNotifPage.dart';
import 'package:qnywhere/owner/ownerProfilepage.dart';

class OwnerPage extends StatefulWidget {
  final String ownerId;
  final int indexNo;
  const OwnerPage({Key? key, required this.ownerId, required this.indexNo})
      : super(key: key);

  @override
  State<OwnerPage> createState() => _OwnerPageState();
}

class _OwnerPageState extends State<OwnerPage> {
  int index = 1;
  final screens = [
    const OwnerProfilePage(),
    const OwnerHomepageScreen(),
    const OwnerNotificationPage()
  ];

  @override
  void initState() {
    super.initState();
    if (widget.indexNo == 0) {
      index = index;
    } else {
      index = widget.indexNo;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorShape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            indicatorColor: const Color.fromARGB(75, 84, 128, 120),
            labelTextStyle: MaterialStateProperty.all(
                const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
        child: NavigationBar(
            height: 60,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            selectedIndex: index,
            onDestinationSelected: (index) => setState(() {
                  this.index = index;
                }),
            destinations: const [
              NavigationDestination(
                  icon: Icon(
                    Icons.person,
                    size: 30,
                  ),
                  label: 'Profile'),
              NavigationDestination(
                  icon: Icon(Icons.home, size: 30), label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.notifications, size: 30),
                  label: 'Notifications'),
            ]),
      ),
      body: screens[index]);
}
