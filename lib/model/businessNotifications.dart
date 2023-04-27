// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessNotifications {
  final String notificationId;
  final String userId;
  final String businessId;
  final String serviceId;
  final String text;
  final Timestamp dateCreated;
  String serviceName;
  BusinessNotifications({
    required this.notificationId,
    required this.userId,
    required this.businessId,
    required this.serviceId,
    required this.text,
    required this.dateCreated,
    this.serviceName = "",
  });

  Map<String, dynamic> toJson() => {
        'notificationId': notificationId,
        'userId': userId,
        'businessName': businessId,
        'serviceId': serviceId,
        'text': text,
        'dateCreated': dateCreated,
        'serviceName': serviceName,
      };

  static BusinessNotifications fromJson(Map<String, dynamic> json) =>
      BusinessNotifications(
        notificationId: json['notificationId'],
        userId: json['userId'],
        businessId: json['businessName'],
        serviceId: json['serviceId'],
        text: json['text'],
        dateCreated: json['dateCreated'],
        serviceName: json['serviceName'],
      );
}
