class Service {
  final String serviceId;
  final String serviceName;
  final String ownerId;
  final String businessName;
  final String businessId;
  final String waitingTime;
  final String servingTime;
  String serving;
  bool inService;
  Service(
      {required this.serviceId,
      required this.serviceName,
      required this.ownerId,
      required this.businessName,
      required this.businessId,
      this.waitingTime = "3",
      this.servingTime = "3",
      this.serving = "1",
      this.inService = false});

  Map<String, dynamic> toJson() => {
        'serviceId': serviceId,
        'serviceName': serviceName,
        'ownerId': ownerId,
        'businessName': businessName,
        'businessId': businessId,
        'waitingTime': waitingTime,
        'servingTime': servingTime,
        'serving': serving,
        'inService': inService,
      };

  static Service fromJson(Map<String, dynamic> json) => Service(
        serviceId: json['serviceId'],
        serviceName: json['serviceName'],
        ownerId: json['ownerId'],
        businessName: json['businessName'],
        businessId: json['businessId'],
        waitingTime: json['waitingTime'],
        servingTime: json['servingTime'],
        serving: json['serving'],
        inService: json['inService'],
      );
}
