// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qnywhere/model/business.dart';

class CheckHistoryPage extends StatefulWidget {
  const CheckHistoryPage({Key? key}) : super(key: key);

  @override
  _CheckHistoryPageState createState() => _CheckHistoryPageState();
}

class _CheckHistoryPageState extends State<CheckHistoryPage> {
  final Color barBackgroundColor = const Color(0xff81e5cd);
  bool haveData = false;
  bool showDaily = true;
  int touchedIndex = -1;

  List<double> weeklyAttendance = [
    5.0,
    3.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
  ];
  final user = FirebaseAuth.instance.currentUser!;

  DateTime findFirstDateOfTheWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 1));
  }

  DateTime findLastDateOfTheWeek(DateTime dateTime) {
    return dateTime
        .add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
  }

  void getData() async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    DateTime currentDate = DateTime.now();
    final String todayFormatted = formatter.format(currentDate);
    DateTime today = DateTime.parse(todayFormatted);
    DateTime firstDayOfWeek = findFirstDateOfTheWeek(today);
    DateTime lastDayOfWeek = findLastDateOfTheWeek(today);
    final businessAccount = await FirebaseFirestore.instance
        .collection('Business Accounts')
        .where('ownerId', isEqualTo: user.uid)
        .get();
    if (businessAccount.docs.isNotEmpty) {
      for (var doc in businessAccount.docs) {
        Map<String, dynamic> data = doc.data();
        List<dynamic> dailyLogs = data['dailyLogs'];
        weeklyAttendance.clear();
        for (int i = 0; i < dailyLogs.length; i++) {
          if (dailyLogs[i]["dateRecorded"]
                      .compareTo(Timestamp.fromDate(firstDayOfWeek)) >
                  0 ||
              dailyLogs[i]["dateRecorded"]
                      .compareTo(Timestamp.fromDate(lastDayOfWeek)) ==
                  0) {
            weeklyAttendance.add(dailyLogs[i]["logs"].toDouble());
          }
        }
        for (int i = weeklyAttendance.length; i < 7; i++) {
          weeklyAttendance.add(0.0);
        }
        print("attendance $weeklyAttendance");
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    getData();
    print("has data $haveData");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff398E7F),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xff398E7F),
          foregroundColor: Colors.white,
          title: Text("History",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        ),
        body: SafeArea(
          child: Center(
              child: Column(children: [
            const SizedBox(height: 15),
            Container(
              height: 230,
              width: 380,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                color: const Color(0xff81e5cd),
                child: Stack(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(left: 15.0, top: 12),
                      child: Text(
                        "Customer Traffic",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 8),
                          child: BarChart(
                            mainBarData(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 11,
            ),
            StreamBuilder<List<Business>>(
                stream: readBusiness(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return Text('Something Went Wrong ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final business = snapshot.data!;
                    if (business.first.businessHistory.isNotEmpty) {
                      return Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                topRight: Radius.circular(15.0),
                                bottomLeft: Radius.circular(15.0),
                                bottomRight: Radius.circular(15.0),
                              )),
                          child: Column(
                            children: [
                              SizedBox(height: 12),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Visit History",
                                  textScaleFactor: 1.5,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Table(
                                    // textDirection: TextDirection.rtl,
                                    // defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
                                    // border:TableBorder.all(width: 2.0,color: Colors.red),
                                    children: const [
                                      TableRow(
                                          decoration: BoxDecoration(
                                              color: Color(0xff398E7F),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15.0),
                                                topRight: Radius.circular(15.0),
                                                bottomLeft:
                                                    Radius.circular(15.0),
                                                bottomRight:
                                                    Radius.circular(15.0),
                                              )),
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: Center(
                                                child: Text(
                                                  "Name",
                                                  textScaleFactor: 1.2,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: Center(
                                                child: Text(
                                                  "Service",
                                                  textScaleFactor: 1.2,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: Center(
                                                child: Text(
                                                  "Time Queued",
                                                  textScaleFactor: 1.2,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ]),
                                    ],
                                  )),
                              Expanded(
                                child: ListView.builder(
                                  itemCount:
                                      business.first.businessHistory.length,
                                  itemBuilder: (context, index) {
                                    final history =
                                        business.first.businessHistory[index];

                                    return buildNotifListView(history);
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                              bottomLeft: Radius.circular(15.0),
                              bottomRight: Radius.circular(15.0),
                            )),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Visit History",
                                textScaleFactor: 1.5,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Table(
                                  // textDirection: TextDirection.rtl,
                                  // defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
                                  // border:TableBorder.all(width: 2.0,color: Colors.red),
                                  children: const [
                                    TableRow(
                                        decoration: BoxDecoration(
                                            color: Color(0xff398E7F),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15.0),
                                              topRight: Radius.circular(15.0),
                                              bottomLeft: Radius.circular(15.0),
                                              bottomRight:
                                                  Radius.circular(15.0),
                                            )),
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Center(
                                              child: Text(
                                                "Name",
                                                textScaleFactor: 1.2,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Center(
                                              child: Text(
                                                "Service",
                                                textScaleFactor: 1.2,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Center(
                                              child: Text(
                                                "Time Queued",
                                                textScaleFactor: 1.2,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ]),
                                  ],
                                )),
                            const SizedBox(
                              height: 50,
                            ),
                            const Center(
                              child: Text("Empty History"),
                            )
                          ],
                        ),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ])),
        ));
  }

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: const Color(0xff81e5cd),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay;
              switch (group.x.toInt()) {
                case 0:
                  weekDay = 'Monday';
                  break;
                case 1:
                  weekDay = 'Tuesday';
                  break;
                case 2:
                  weekDay = 'Wednesday';
                  break;
                case 3:
                  weekDay = 'Thursday';
                  break;
                case 4:
                  weekDay = 'Friday';
                  break;
                case 5:
                  weekDay = 'Saturday';
                  break;
                case 6:
                  weekDay = 'Sunday';
                  break;
                default:
                  throw Error();
              }
              return BarTooltipItem(
                weekDay + '\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: (rod.toY - 1).toString(),
                    style: const TextStyle(
                      color: Color(0xff294243),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: FlGridData(show: false),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('M', style: style);
        break;
      case 1:
        text = const Text('T', style: style);
        break;
      case 2:
        text = const Text('W', style: style);
        break;
      case 3:
        text = const Text('T', style: style);
        break;
      case 4:
        text = const Text('F', style: style);
        break;
      case 5:
        text = const Text('S', style: style);
        break;
      case 6:
        text = const Text('S', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, weeklyAttendance[0],
                isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, weeklyAttendance[1],
                isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, weeklyAttendance[2],
                isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(3, weeklyAttendance[3],
                isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(4, weeklyAttendance[4],
                isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(5, weeklyAttendance[5],
                isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(6, weeklyAttendance[6],
                isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.white,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched ? const Color(0xff294243) : barColor,
          width: width,
          borderSide: isTouched
              ? const BorderSide(color: Color(0xff294243), width: 1)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  Widget buildNotifListView(History history) {
    DateTime date = history.timeQueued.toDate();
    String formatDate = DateFormat('yyyy-MM-dd – kk:mm').format(date);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10, right: 20),
          child: Container(
            child: Center(
              child: Text(
                history.fullName,
                textScaleFactor: 1,
                textAlign: TextAlign.start,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10, right: 20),
          child: Center(
            child: Text(
              history.serviceName,
              textScaleFactor: 1,
              textAlign: TextAlign.start,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10, right: 15),
          child: Center(
            child: Text(
              formatDate,
              textScaleFactor: 1,
              textAlign: TextAlign.start,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

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
}
