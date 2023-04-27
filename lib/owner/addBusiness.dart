// ignore_for_file: file_names, avoid_print, use_build_context_synchronously
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qnywhere/components/addBusiness_textfield.dart';
import 'package:qnywhere/model/business.dart';
import 'package:qnywhere/owner/ownerPage.dart';
import 'package:uuid/uuid.dart';

class AddBusiness extends StatefulWidget {
  final String ownerID;
  const AddBusiness({Key? key, required this.ownerID}) : super(key: key);

  @override
  State<AddBusiness> createState() => _AddBusinessState();
}

class _AddBusinessState extends State<AddBusiness> {
  TextEditingController name = TextEditingController();
  TextEditingController location = TextEditingController();
  final types = [
    'School',
    'Hospital',
    'Store',
    'Pharmacy',
    'Restaurant',
    'Bank'
  ];
  String selectedType = 'School';
  File? image;
  String imageUrl = "";
  var uuid = const Uuid();
  String _uid = "";
  String dateUploaded = "";
  Future pickImageGallery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() {
        this.image = imageTemporary;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImageCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() {
        this.image = imageTemporary;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
    Navigator.pop(context);
  }

  void removeImage() {
    setState(() {
      image = null;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(0xff398E7F),
        foregroundColor: Colors.white,
        title: const Padding(
          padding: EdgeInsets.only(left: 50),
          child: Center(
            child: Text("Business Info",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
          ),
        ),
        actions: [
          GestureDetector(
              onTap: (() async {
                List<TimeRecord> dailyWaitingTime = const [];
                List<TimeRecord> weeklyWaitingTime = const [];
                List<TimeRecord> dailyServingTime = const [];
                List<TimeRecord> weeklyServingTime = const [];
                List<AttendanceRecord> dailyLogs = const [];
                List<History> businessHistory = const [];
                _uid = uuid.v4();
                try {
                  if (image != null) {
                    final ref = FirebaseStorage.instance
                        .ref()
                        .child('Business Image')
                        .child(_uid)
                        .child('$_uid.jpg');
                    await ref.putFile(image!);
                    imageUrl = await ref.getDownloadURL();
                  }

                  final uploadTime = DateTime.now();
                  Timestamp myTimeStamp = Timestamp.fromDate(uploadTime);

                  final docBusiness = FirebaseFirestore.instance
                      .collection('Business Accounts')
                      .doc(_uid);

                  final data = {
                    'businessId': _uid,
                    'ownerId': widget.ownerID,
                    'businessImageUrl': imageUrl,
                    'businessName': name.text,
                    'businessLocation': location.text,
                    'businessType': selectedType,
                    'dateCreated': myTimeStamp,
                    'dateRecorded': myTimeStamp,
                    'dailyWaitingTime': dailyWaitingTime,
                    'weeklyWaitingTime': weeklyWaitingTime,
                    'dailyServingTime': dailyServingTime,
                    'weeklyServingTime': weeklyServingTime,
                    'dailyAvgServingTime': "0",
                    'dailyAvgWaitingTime': "0",
                    'weeklyAvgServingTime': "0",
                    'weeklyAvgWaitingTime': "0",
                    'dailyLogs': dailyLogs,
                    'businessHistory': businessHistory,
                  };
                  docBusiness.set(data);
                } catch (e) {
                  print(e);
                }
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) =>
                        OwnerPage(ownerId: widget.ownerID, indexNo: 0)));
              }),
              child: const Center(
                  child: Padding(
                padding: EdgeInsets.only(right: 20),
                child: Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              )))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    color: Color(0xff398E7F),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0),
                    )),
                child: GestureDetector(
                  onTap: (() {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              'Choose option',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                            ),
                            content: SingleChildScrollView(
                              child: ListBody(children: [
                                InkWell(
                                  onTap: pickImageCamera,
                                  child: Row(
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.camera,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Camera',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      )
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: pickImageGallery,
                                  child: Row(
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Gallery',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      )
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: removeImage,
                                  child: Row(
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.remove_circle,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Remove',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      )
                                    ],
                                  ),
                                )
                              ]),
                            ),
                          );
                        });
                  }),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 90, vertical: 30),
                    decoration: BoxDecoration(
                        color: const Color(0xffD9D9D9),
                        borderRadius: BorderRadius.circular(30)),
                    child: ClipRect(
                      child: image != null
                          ? Image.file(
                              image!,
                              width: 350,
                              height: 250,
                              fit: BoxFit.fill,
                            )
                          : const Center(
                              child: Icon(
                              Icons.add_circle,
                              size: 30,
                            )),
                    ),
                  ),
                )),
            Container(
              height: MediaQuery.of(context).size.height * 0.70,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 35, top: 20),
                    child: Text("Basic Information",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xff398E7F))),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Container(
                      height: 110,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                          color: const Color(0xff398E7F),
                          borderRadius: BorderRadius.circular(30)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 15, left: 25),
                            child: Text("Business Name",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                    color: Colors.white)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, top: 5),
                            child: AddBusinessInput(
                              icon: Icons.person,
                              hint: 'First Name',
                              controller: name,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Container(
                      height: 110,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                          color: const Color(0xff398E7F),
                          borderRadius: BorderRadius.circular(30)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 15, left: 25),
                            child: Text("Business Location",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                    color: Colors.white)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, top: 5),
                            child: AddBusinessInput(
                              icon: Icons.person,
                              hint: '',
                              controller: location,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Container(
                      height: 110,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                          color: const Color(0xff398E7F),
                          borderRadius: BorderRadius.circular(30)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 15, left: 25),
                            child: Text("Type of Business",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                    color: Colors.white)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 5, left: 22, right: 22),
                            child: DropdownButtonFormField(
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 18,
                                  color: Color(0xff398E7F)),
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xff398E7F), width: 2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xff398E7F), width: 2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                filled: true,
                                fillColor:
                                    const Color.fromRGBO(225, 225, 225, 50),
                              ),
                              validator: (value) => value == null
                                  ? "Select a Type of Business"
                                  : null,
                              dropdownColor: Colors.white,
                              value: selectedType,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedType = newValue!;
                                });
                              },
                              items: types.map((String val) {
                                return DropdownMenuItem(
                                  value: val,
                                  child: Text(
                                    val,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
