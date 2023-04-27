import 'package:cloud_firestore/cloud_firestore.dart';

class UserNotifications {
  final String notificationId;
  final String userId;
  final String businessName;
  final String text;
  final Timestamp dateCreated;
  String serviceName;
  String instruction;
  bool hasIntruction;
  UserNotifications(
      {required this.notificationId,
      required this.userId,
      required this.businessName,
      required this.text,
      required this.dateCreated,
      this.serviceName = "",
      this.instruction = "",
      this.hasIntruction = false});

  Map<String, dynamic> toJson() => {
        'notificationId': notificationId,
        'userId': userId,
        'businessName': businessName,
        'text': text,
        'dateCreated': dateCreated,
        'serviceName': serviceName,
        'instruction': instruction,
        'hasIntruction': hasIntruction,
      };

  static UserNotifications fromJson(Map<String, dynamic> json) =>
      UserNotifications(
        notificationId: json['notificationId'],
        userId: json['userId'],
        businessName: json['businessName'],
        text: json['text'],
        dateCreated: json['dateCreated'],
        serviceName: json['serviceName'],
        instruction: json['instruction'],
        hasIntruction: json['hasIntruction'],
      );
}
