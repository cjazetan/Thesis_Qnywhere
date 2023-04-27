import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String accountId;
  final String accountEmail;
  final String accountFirstName;
  final String accountLastName;
  final String accountPhoneNumber;
  String imageUrl;
  final Timestamp dateCreated;
  List<Recents> recents;
  Users({
    required this.accountId,
    required this.accountEmail,
    required this.accountFirstName,
    required this.accountLastName,
    required this.accountPhoneNumber,
    this.imageUrl = "",
    required this.dateCreated,
    this.recents = const [],
  });

  Map<String, dynamic> toJson() => {
        'accountID': accountId,
        'accountEmail': accountEmail,
        'accountFirstName': accountFirstName,
        'accountLastName': accountLastName,
        'accountPhoneNumber': accountPhoneNumber,
        'imageUrl': imageUrl,
        'dateCreated': dateCreated,
      };

  static Users fromJson(Map<String, dynamic> json) => Users(
      accountId: json['accountID'],
      accountEmail: json['accountEmail'],
      accountFirstName: json['accountFirstName'],
      accountLastName: json['accountLastName'],
      accountPhoneNumber: json['accountPhoneNumber'],
      imageUrl: json['imageUrl'],
      dateCreated: json['dateCreated'],
      recents: Recents.fromJsonArray(json['recentQueued']));
}

class Recents {
  final String queueId;
  final String businessId;
  final String serviceId;
  final String businessImageUrl;
  final String businessLocation;
  final String businessName;

  Recents(
      {required this.queueId,
      required this.businessId,
      required this.serviceId,
      required this.businessImageUrl,
      required this.businessLocation,
      required this.businessName});

  factory Recents.fromJson(Map<String, dynamic> json) {
    return Recents(
      queueId: json['queueId'],
      businessId: json['businessId'],
      serviceId: json['serviceId'],
      businessImageUrl: json['businessImageUrl'],
      businessLocation: json['businessLocation'],
      businessName: json['businessName'],
    );
  }

  static List<Recents> fromJsonArray(List<dynamic> jsonArray) {
    List<Recents> votesFromJson = [];

    jsonArray.forEach((jsonData) {
      votesFromJson.add(Recents.fromJson(jsonData));
    });
    return votesFromJson;
  }
}
