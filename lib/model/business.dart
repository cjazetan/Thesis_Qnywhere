import 'package:cloud_firestore/cloud_firestore.dart';

class Business {
  final String businessId;
  final String ownerId;
  final String businessImageUrl;
  final String businessName;
  final String businessLocation;
  final String businessType;
  String dailyAvgServingTime;
  String dailyAvgWaitingTime;
  String weeklyAvgServingTime;
  String weeklyAvgWaitingTime;
  Timestamp dateCreated;
  List<TimeRecord> dailyWaitingTime;
  List<TimeRecord> weeklyWaitingTime;
  List<TimeRecord> dailyServingTime;
  List<TimeRecord> weeklyServingTime;
  List<AttendanceRecord> dailyLogs;
  List<History> businessHistory;
  Business({
    required this.businessId,
    required this.ownerId,
    required this.businessImageUrl,
    required this.businessName,
    required this.businessLocation,
    required this.businessType,
    required this.dateCreated,
    this.dailyAvgServingTime = "",
    this.dailyAvgWaitingTime = "",
    this.weeklyAvgServingTime = "",
    this.weeklyAvgWaitingTime = "",
    this.dailyWaitingTime = const [],
    this.weeklyWaitingTime = const [],
    this.dailyServingTime = const [],
    this.weeklyServingTime = const [],
    this.dailyLogs = const [],
    this.businessHistory = const [],
  });

  Map<String, dynamic> toJson() => {
        'businessId': businessId,
        'ownerId': ownerId,
        'businessImageUrl': businessImageUrl,
        'businessName': businessName,
        'businessLocation': businessLocation,
        'businessType': businessType,
        'dateCreated': dateCreated,
        'dailyAvgServingTime': dailyAvgServingTime,
        'dailyAvgWaitingTime': dailyAvgWaitingTime,
        'weeklyAvgServingTime': weeklyAvgServingTime,
        'weeklyAvgWaitingTime': weeklyAvgWaitingTime,
        'dailyWaitingTime': dailyWaitingTime,
        'weeklyWaitingTime': weeklyWaitingTime,
        'dailyServingTime': dailyServingTime,
        'weeklyServingTime': weeklyServingTime,
        'dailyLogs': dailyLogs,
        'businessHistory': businessHistory,
      };

  static Business fromJson(Map<String, dynamic> json) => Business(
        businessId: json['businessId'],
        ownerId: json['ownerId'],
        businessImageUrl: json['businessImageUrl'],
        businessName: json['businessName'],
        businessLocation: json['businessLocation'],
        businessType: json['businessType'],
        dateCreated: json['dateCreated'],
        dailyAvgServingTime: json['dailyAvgServingTime'],
        dailyAvgWaitingTime: json['dailyAvgWaitingTime'],
        weeklyAvgServingTime: json['weeklyAvgServingTime'],
        weeklyAvgWaitingTime: json['weeklyAvgWaitingTime'],
        dailyWaitingTime: TimeRecord.fromJsonArray(json['dailyWaitingTime']),
        weeklyWaitingTime: TimeRecord.fromJsonArray(json['weeklyWaitingTime']),
        dailyServingTime: TimeRecord.fromJsonArray(json['dailyServingTime']),
        weeklyServingTime: TimeRecord.fromJsonArray(json['weeklyServingTime']),
        dailyLogs: AttendanceRecord.fromJsonArray(json['dailyLogs']),
        businessHistory: History.fromJsonArray(json['businessHistory']),
      );
}

class TimeRecord {
  final Timestamp dateRecorded;
  final String time;

  TimeRecord({
    required this.dateRecorded,
    required this.time,
  });

  factory TimeRecord.fromJson(Map<String, dynamic> json) {
    return TimeRecord(
      dateRecorded: json['dateRecorded'],
      time: json['time'],
    );
  }

  static List<TimeRecord> fromJsonArray(List<dynamic> jsonArray) {
    List<TimeRecord> timeRecorded = [];

    jsonArray.forEach((jsonData) {
      timeRecorded.add(TimeRecord.fromJson(jsonData));
    });
    return timeRecorded;
  }
}

class AttendanceRecord {
  final Timestamp dateRecorded;
  final int logs;

  AttendanceRecord({
    required this.dateRecorded,
    required this.logs,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      dateRecorded: json['dateRecorded'],
      logs: json['logs'],
    );
  }

  static List<AttendanceRecord> fromJsonArray(List<dynamic> jsonArray) {
    List<AttendanceRecord> attendanceRecord = [];

    jsonArray.forEach((jsonData) {
      attendanceRecord.add(AttendanceRecord.fromJson(jsonData));
    });
    return attendanceRecord;
  }
}

class History {
  final String queueId;
  final String businessId;
  final String fullName;
  final String waitingDuration;
  final String servingDuration;
  final String serviceName;
  final Timestamp timeQueued;

  History(
      {required this.queueId,
      required this.businessId,
      required this.fullName,
      required this.waitingDuration,
      required this.servingDuration,
      required this.serviceName,
      required this.timeQueued});

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      queueId: json['queueId'],
      businessId: json['businessId'],
      fullName: json['fullName'],
      waitingDuration: json['waitingDuration'],
      servingDuration: json['servingDuration'],
      serviceName: json['serviceName'],
      timeQueued: json['timeQueued'],
    );
  }

  static List<History> fromJsonArray(List<dynamic> jsonArray) {
    List<History> historyFromJson = [];

    jsonArray.forEach((jsonData) {
      historyFromJson.add(History.fromJson(jsonData));
    });
    return historyFromJson;
  }
}
