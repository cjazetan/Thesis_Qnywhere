import 'package:cloud_firestore/cloud_firestore.dart';

class Queue {
  final String queueId;
  final int queueNumber;
  final String serviceId;
  final String serviceName;
  final String businessId;
  final String accountId;
  final Timestamp timeQueued;
  final Timestamp estimatedTime;
  final String fullName;
  final String mobileNumber;
  String servingDuration;
  String waitingDuration;
  String instruction;
  bool hasInstruction;
  bool isCancel;
  bool isDone;
  bool isRemoved;
  bool isNotifiedCancelled;
  bool notiyfNextInLine;
  bool notiyfTurnComingUp;
  bool isCancelCustomer;
  Queue({
    required this.queueId,
    required this.serviceName,
    required this.queueNumber,
    required this.serviceId,
    required this.businessId,
    required this.accountId,
    required this.timeQueued,
    required this.estimatedTime,
    required this.fullName,
    required this.mobileNumber,
    this.servingDuration = "",
    this.waitingDuration = "",
    this.instruction = "",
    this.hasInstruction = false,
    this.isCancel = false,
    this.isDone = false,
    this.isRemoved = false,
    this.isNotifiedCancelled = false,
    this.notiyfNextInLine = false,
    this.notiyfTurnComingUp = false,
    this.isCancelCustomer = false,
  });

  Map<String, dynamic> toJson() => {
        'queueId': queueId,
        'serviceName': serviceName,
        'queueNumber': queueNumber,
        'serviceId': serviceId,
        'businessId': businessId,
        'accountId': accountId,
        'timeQueued': timeQueued,
        'estimatedTime': estimatedTime,
        'fullName': fullName,
        'mobileNumber': mobileNumber,
        'servingDuration': servingDuration,
        'waitingDuration': waitingDuration,
        'instruction': instruction,
        'hasInstruction': hasInstruction,
        'isCancel': isCancel,
        'isDone': isDone,
        'isRemoved': isRemoved,
        'isNotifiedCancelled': isNotifiedCancelled,
        'notiyfNextInLine': notiyfNextInLine,
        'notiyfTurnComingUp': notiyfTurnComingUp,
        'isCancelCustomer': isCancelCustomer,
      };

  static Queue fromJson(Map<String, dynamic> json) => Queue(
        queueId: json['queueId'],
        serviceName: json['serviceName'],
        queueNumber: json['queueNumber'],
        serviceId: json['serviceId'],
        businessId: json['businessId'],
        accountId: json['accountId'],
        timeQueued: json['timeQueued'],
        estimatedTime: json['estimatedTime'],
        fullName: json['fullName'],
        mobileNumber: json['mobileNumber'],
        servingDuration: json['servingDuration'],
        waitingDuration: json['waitingDuration'],
        instruction: json['instruction'],
        hasInstruction: json['hasInstruction'],
        isCancel: json['isCancel'],
        isDone: json['isDone'],
        isRemoved: json['isRemoved'],
        isNotifiedCancelled: json['isNotifiedCancelled'],
        notiyfNextInLine: json['notiyfNextInLine'],
        notiyfTurnComingUp: json['notiyfTurnComingUp'],
        isCancelCustomer: json['isCancelCustomer'],
      );
}
