import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qnywhere/owner/checkHistory.dart';

class BusinessStatistics extends StatefulWidget {
  const BusinessStatistics({Key? key}) : super(key: key);

  @override
  _BusinessStatisticsState createState() => _BusinessStatisticsState();
}

class _BusinessStatisticsState extends State<BusinessStatistics> {
  final Color barBackgroundColor = const Color(0xff81e5cd);
  bool haveData = false;
  bool showDaily = true;
  int touchedIndex = -1;
  String dailyAvgServingTime = "";
  String dailyAvgWaitingTime = "";
  String weeklyAvgServingTime = "";
  String weeklyAvgWaitingTime = "";
  List<FlSpot> dailyServingPlots = [];
  List<FlSpot> weeklyServingPlots = [];
  List<FlSpot> dailyWaitingPlots = [];
  List<FlSpot> weeklyWaitingPlots = [];
  List<double> weeklyAttendance = [];
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
        Timestamp dateRecorded = data['dateRecorded'];
        String businessId = data['businessId'];
        dailyAvgServingTime = data['dailyAvgServingTime'];
        dailyAvgWaitingTime = data['dailyAvgWaitingTime'];
        weeklyAvgServingTime = data['weeklyAvgServingTime'];
        weeklyAvgWaitingTime = data['weeklyAvgWaitingTime'];
        List<dynamic> dailyServingTime = data['dailyServingTime'];
        List<dynamic> dailyWaitingTime = data['dailyWaitingTime'];
        List<dynamic> weeklyServingTime = data['weeklyServingTime'];
        List<dynamic> weeklyWaitingTime = data['weeklyWaitingTime'];
        List<dynamic> dailyLogs = data['dailyLogs'];

        double finaldailyAvgServingTime =
            double.parse(dailyAvgServingTime) / 60;
        double roundfinaldailyAvgServingTime =
            double.parse((finaldailyAvgServingTime).toStringAsFixed(2));
        dailyAvgServingTime = roundfinaldailyAvgServingTime.toString();

        double finaldailyWaitingTime = double.parse(dailyAvgWaitingTime) / 60;
        double roundfinaldailyWaitingTime =
            double.parse((finaldailyWaitingTime).toStringAsFixed(2));
        dailyAvgWaitingTime = roundfinaldailyWaitingTime.toString();

        double finalWeeklyWaitingTime = double.parse(weeklyAvgWaitingTime) / 60;
        double roundfinalWeeklyWaitingTime =
            double.parse((finalWeeklyWaitingTime).toStringAsFixed(2));
        weeklyAvgWaitingTime = roundfinalWeeklyWaitingTime.toString();

        double finalWeeklyServingTime = double.parse(weeklyAvgServingTime) / 60;
        double roundfinalWeeklyServingTime =
            double.parse((finalWeeklyServingTime).toStringAsFixed(2));
        weeklyAvgServingTime = roundfinalWeeklyServingTime.toString();

        double counterdailyServingTime = 0;
        double counterdailyWaitingTime = 0;
        double counterWeeklyServingTime = 0;
        double counterWeeklyWaitingTime = 0;

        for (int i = 0; i < dailyServingTime.length; i++) {
          double y = double.parse(dailyServingTime[i]["time"]) / 60;
          double yRound = double.parse((y).toStringAsFixed(2));
          dailyServingPlots.add(FlSpot(counterdailyServingTime, (yRound)));
          counterdailyServingTime++;
        }
        for (int i = 0; i < dailyWaitingTime.length; i++) {
          double y = double.parse(dailyWaitingTime[i]["time"]) / 60;
          double yRound = double.parse((y).toStringAsFixed(2));
          dailyWaitingPlots.add(FlSpot(counterdailyWaitingTime, (yRound)));
          counterdailyWaitingTime++;
        }
        for (int i = 0; i < weeklyWaitingTime.length; i++) {
          double y = double.parse(weeklyWaitingTime[i]["time"]) / 60;
          double yRound = double.parse((y).toStringAsFixed(2));
          weeklyWaitingPlots.add(FlSpot(counterWeeklyWaitingTime, (yRound)));
          counterWeeklyWaitingTime++;
        }

        for (int i = 0; i < weeklyServingTime.length; i++) {
          double y = double.parse(weeklyServingTime[i]["time"]) / 60;
          double yRound = double.parse((y).toStringAsFixed(2));
          weeklyServingPlots.add(FlSpot(counterWeeklyServingTime, (yRound)));
          counterWeeklyServingTime++;
        }

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
        print(dailyServingTime.length);
        print(weeklyServingTime.length);

        if (dailyAvgServingTime.isEmpty || weeklyAvgServingTime.isEmpty) {
          haveData = false;
        } else {
          setState(() {
            haveData = true;
          });
        }
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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xff398E7F),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff398E7F),
        foregroundColor: Colors.white,
        title: Text("Check Statistics",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
      ),
      body: SafeArea(
        child: (haveData == true)
            ? Column(
                children: [
                  SizedBox(height: 15),
                  Center(child: startService(size)),
                  SizedBox(height: 20),
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40.0),
                          topRight: Radius.circular(40.0),
                        )),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 160),
                          child: Divider(
                            thickness: 5,
                            color: Color(0xff294243),
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                                onTap: (() {
                                  if (showDaily == false) {
                                    setState(() {
                                      showDaily = true;
                                    });
                                  }
                                }),
                                child: Text(
                                  "Day",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: (showDaily == true)
                                          ? Color(0xff398E7F)
                                          : Color(0xff61C5B3)),
                                )),
                            SizedBox(
                              width: 20,
                            ),
                            GestureDetector(
                                onTap: (() {
                                  if (showDaily == true) {
                                    setState(() {
                                      showDaily = false;
                                    });
                                  }
                                }),
                                child: Text(
                                  "Week",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: (showDaily == false)
                                          ? Color(0xff398E7F)
                                          : Color(0xff61C5B3)),
                                )),
                          ],
                        ),
                        SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: Material(
                                elevation: 5,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(18),
                                ),
                                child: Container(
                                  decoration:
                                      const BoxDecoration(color: Colors.white),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 8.0, left: 8.0, top: 8),
                                        child: Text(
                                          "Average Waiting Time",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 8.0,
                                            left: 8.0,
                                            top: 24,
                                            bottom: 8),
                                        child: showDaily
                                            ? Text(
                                                "$dailyAvgWaitingTime min",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                    color: Color(0xff3EB9A3)),
                                              )
                                            : Text(
                                                "$weeklyAvgWaitingTime min",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                    color: Color(0xff3EB9A3)),
                                              ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 12.0,
                                            left: 12.0,
                                            top: 56,
                                            bottom: 5),
                                        child: LineChart(
                                          waitingData(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: Material(
                                elevation: 5,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(18),
                                ),
                                child: Container(
                                  decoration:
                                      const BoxDecoration(color: Colors.white),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 8.0, left: 8.0, top: 8),
                                        child: Text(
                                          "Average Serving Time",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 8.0,
                                            left: 8.0,
                                            top: 24,
                                            bottom: 8),
                                        child: showDaily
                                            ? Text(
                                                "$dailyAvgServingTime min",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                    color: Color(0xff3EB9A3)),
                                              )
                                            : Text(
                                                "$weeklyAvgServingTime min",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                    color: Color(0xff3EB9A3)),
                                              ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 12.0,
                                            left: 12.0,
                                            top: 56,
                                            bottom: 5),
                                        child: LineChart(
                                          servingData(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Container(
                          height: 280,
                          width: 380,
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            color: const Color(0xff81e5cd),
                            child: Stack(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, top: 12),
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
                                      padding: const EdgeInsets.only(
                                          top: 24, bottom: 8),
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
                        SizedBox(
                          height: 11,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Stack(
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
                                    color: Colors.black,
                                    offset: Offset(0, 10),
                                    blurRadius: 10),
                              ]),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Business Statistics Is Not Available",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "New Business Accounts must log for at least a week in Qnywhere app in order for the statistical team to gather enough data to produce your very own business statistics",
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
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(55)),
                                child: Image.asset("assets/images/hero.png")),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Color(0xff81e5cd),
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
            return makeGroupData(3, (weeklyAttendance[3]),
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
          color: isTouched ? Color(0xff294243) : barColor,
          width: width,
          borderSide: isTouched
              ? BorderSide(color: Color(0xff294243), width: 1)
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

  LineChartData waitingData() {
    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff398E7F),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff398E7F),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: false,
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: (showDaily == true)
          ? double.parse(dailyWaitingPlots.length.toString())
          : double.parse(weeklyWaitingPlots.length.toString()),
      minY: 0,
      maxY: 5,
      lineBarsData: [
        LineChartBarData(
          spots: (showDaily == true) ? dailyWaitingPlots : weeklyWaitingPlots,
          isCurved: true,
          color: const Color(0xff81e5cd),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
        ),
      ],
    );
  }

  LineChartData servingData() {
    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff398E7F),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff398E7F),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: false,
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: (showDaily == true)
          ? double.parse(dailyServingPlots.length.toString())
          : double.parse(weeklyServingPlots.length.toString()),
      minY: 0,
      maxY: 5,
      lineBarsData: [
        LineChartBarData(
          spots: (showDaily == true) ? dailyServingPlots : weeklyServingPlots,
          isCurved: true,
          color: const Color(0xff81e5cd),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
        ),
      ],
    );
  }

  InkWell startService(Size size) {
    return InkWell(
      onTap: (() {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const CheckHistoryPage()));
      }),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: size.width * 0.30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        child: const Text(
          'View History',
          style: TextStyle(
              color: Color(0xff294243),
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
