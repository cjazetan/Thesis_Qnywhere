// ignore_for_file: file_names, avoid_print, use_build_context_synchronously
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qnywhere/components/addBusiness_textfield.dart';
import 'package:qnywhere/model/business.dart';
import 'package:qnywhere/owner/ownerPage.dart';

class EditBusiness extends StatefulWidget {
  const EditBusiness({Key? key}) : super(key: key);

  @override
  State<EditBusiness> createState() => _EditBusinessState();
}

class _EditBusinessState extends State<EditBusiness> {
  final User user = FirebaseAuth.instance.currentUser!;
  TextEditingController name = TextEditingController();
  TextEditingController location = TextEditingController();
  bool editName = false;
  bool editLocation = false;
  bool editImage = false;
  final types = [
    'School',
    'Hospital',
    'Store',
    'Pharmacy',
    'Restaurant',
    'Other'
  ];
  String prevName = "";
  String prevLocation = "";
  String selectedType = 'School';
  File? image;
  String imageUrl = "";
  String prevImageUr = "";
  String businessId = "";
  String dateUploaded = "";
  Future pickImageGallery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemporary = File(image.path);
      editImage = true;
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
      editImage = true;
      setState(() {
        this.image = imageTemporary;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
    Navigator.pop(context);
  }

  void removeImage() {
    editImage = false;
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
                try {
                  if (image != null) {
                    final ref = FirebaseStorage.instance
                        .ref()
                        .child('Business Image')
                        .child(user.uid)
                        .child('${user.uid}.jpg');
                    await ref.putFile(image!);
                    imageUrl = await ref.getDownloadURL();
                  }

                  if (image == null) {
                    imageUrl = prevImageUr;
                  }
                  if (name.text.isEmpty) {
                    name.text = prevName;
                  }

                  if (location.text.isEmpty) {
                    location.text = prevLocation;
                  }

                  setState(() {});

                  final docBusiness = FirebaseFirestore.instance
                      .collection('Business Accounts')
                      .doc(businessId);

                  final data = {
                    'businessImageUrl': imageUrl,
                    'businessName': name.text,
                    'businessLocation': location.text,
                    'businessType': selectedType,
                  };
                  docBusiness.update(data);
                } catch (e) {
                  print(e);
                }
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => OwnerPage(
                          ownerId: user.uid,
                          indexNo: 0,
                        )));
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
      body: SafeArea(
        child: StreamBuilder<List<Business>>(
            stream: readBusiness(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something Went Wrong');
              } else if (snapshot.hasData) {
                final business = snapshot.data!;
                print(business.isNotEmpty);
                prevImageUr = business.first.businessImageUrl;
                businessId = business.first.businessId;
                prevName = business.first.businessName;
                prevLocation = business.first.businessLocation;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
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
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 90, vertical: 30),
                                decoration: BoxDecoration(
                                    color: const Color(0xffD9D9D9),
                                    borderRadius: BorderRadius.circular(30)),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: (editImage == false)
                                        ? Image.network(
                                            business.first.businessImageUrl,
                                            width: 350,
                                            height: 250,
                                            fit: BoxFit.fill)
                                        : Image.file(
                                            image!,
                                            width: 350,
                                            height: 250,
                                            fit: BoxFit.fill,
                                          )),
                              )),
                          Positioned(
                            left: 95,
                            top: 35,
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
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.camera,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Camera',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.image,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Gallery',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.remove_circle,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Remove',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                width: 100,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xff398E7F),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Change Image',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(
                                              top: 15, left: 25),
                                          child: Text("Business Name",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16,
                                                  color: Colors.white)),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (editName == true) {
                                              editName = false;
                                            } else {
                                              editName = true;
                                            }

                                            setState(() {
                                              print(editName);
                                            });
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 15),
                                            child: Container(
                                                width: 50,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xff398E7F),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                                child: const Icon(
                                                  Icons
                                                      .mode_edit_outline_outlined,
                                                  color: Colors.white,
                                                  size: 16,
                                                )),
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: 25, top: 5),
                                        child: (editName == true)
                                            ? AddBusinessInput(
                                                icon: Icons.person,
                                                hint: '',
                                                controller: name,
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: Text(
                                                    business.first.businessName,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 18,
                                                        color: Colors.white)),
                                              )),
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(
                                              top: 15, left: 25),
                                          child: Text("Business Location",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16,
                                                  color: Colors.white)),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (editLocation == true) {
                                              editLocation = false;
                                            } else {
                                              editLocation = true;
                                            }
                                            setState(() {
                                              print(editLocation);
                                            });
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 15),
                                            child: Container(
                                                width: 50,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xff398E7F),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                                child: const Icon(
                                                  Icons
                                                      .mode_edit_outline_outlined,
                                                  color: Colors.white,
                                                  size: 16,
                                                )),
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: 25, top: 5),
                                        child: (editLocation == true)
                                            ? AddBusinessInput(
                                                icon: Icons.person,
                                                hint: '',
                                                controller: location,
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: Text(
                                                    business
                                                        .first.businessLocation,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 18,
                                                        color: Colors.white)),
                                              )),
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
                                      padding:
                                          EdgeInsets.only(top: 15, left: 25),
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
                                            color: Colors.black),
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Color(0xff398E7F),
                                                width: 2),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Color(0xff398E7F),
                                                width: 2),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          filled: true,
                                          fillColor: const Color.fromRGBO(
                                              225, 225, 225, 50),
                                        ),
                                        validator: (value) => value == null
                                            ? "Select a Type of Business"
                                            : null,
                                        dropdownColor: Colors.white,
                                        value: business.first.businessType,
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
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
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
