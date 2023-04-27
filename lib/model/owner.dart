import 'package:cloud_firestore/cloud_firestore.dart';

class Owner {
  final String accountId;
  final String accountEmail;
  final String accountFirstName;
  final String accountLastName;
  final String accountPhoneNumber;
  final bool haveBusiness;
  String imageUrl;
  final Timestamp dateCreated;

  Owner({
    required this.accountId,
    required this.accountEmail,
    required this.accountFirstName,
    required this.accountLastName,
    required this.accountPhoneNumber,
    required this.haveBusiness,
    this.imageUrl = "",
    required this.dateCreated,
  });

  Map<String, dynamic> toJson() => {
        'accountID': accountId,
        'accountEmail': accountEmail,
        'accountFirstName': accountFirstName,
        'accountLastName': accountLastName,
        'accountPhoneNumber': accountPhoneNumber,
        'haveBusiness': haveBusiness,
        'imageUrl': imageUrl,
        'dateCreated': dateCreated,
      };

  static Owner fromJson(Map<String, dynamic> json) => Owner(
        accountId: json['accountID'],
        accountEmail: json['accountEmail'],
        accountFirstName: json['accountFirstName'],
        accountLastName: json['accountLastName'],
        accountPhoneNumber: json['accountPhoneNumber'],
        haveBusiness: json['haveBusiness'],
        imageUrl: json['imageUrl'],
        dateCreated: json['dateCreated'],
      );
}
