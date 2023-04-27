// ignore_for_file: file_names, avoid_print, use_build_context_synchronously
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qnywhere/components/addBusiness_textfield.dart';
import 'package:qnywhere/model/owner.dart';
import 'package:qnywhere/owner/ownerPage.dart';
import 'package:uuid/uuid.dart';

class EditOwner extends StatefulWidget {
  const EditOwner({Key? key}) : super(key: key);

  @override
  State<EditOwner> createState() => _EditOwnerState();
}

class _EditOwnerState extends State<EditOwner> {
  final User user = FirebaseAuth.instance.currentUser!;
  TextEditingController firtstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  bool editName = false;
  bool editLocation = false;
  bool editEmail = false;
  bool editPhone = false;
  bool editImage = false;
  File? image;
  String imageUrl = "";
  String previmageUrl = "";
  String prevFirst = "";
  String prevLast = "";
  String prevEmail = "";
  String prevPhone = "";
  var uuid = const Uuid();
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
        elevation: 0,
        backgroundColor: const Color(0xff398E7F),
        foregroundColor: Colors.white,
        title: const Padding(
          padding: EdgeInsets.only(left: 50),
          child: Center(
            child: Text("Owner Info",
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
                        .child('Owner Accounts')
                        .child(user.uid)
                        .child('${user.uid}.jpg');
                    await ref.putFile(image!);
                    imageUrl = await ref.getDownloadURL();
                  }

                  final docOwner = FirebaseFirestore.instance
                      .collection('Owner Accounts')
                      .doc(user.uid);

                  final data = {
                    'accountFirstName': firtstName.text,
                    'accountLastName': lastName.text,
                    'accountPhoneNumber': phoneNumber.text,
                    'accountEmail': email.text,
                    'imageUrl': imageUrl,
                  };
                  docOwner.update(data);
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
        child: StreamBuilder<List<Owner>>(
            stream: readOwner(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something Went Wrong');
              } else if (snapshot.hasData) {
                final owner = snapshot.data!;
                print(owner.isNotEmpty);
                firtstName.text = owner.first.accountFirstName;
                lastName.text = owner.first.accountLastName;
                phoneNumber.text = owner.first.accountPhoneNumber;
                email.text = owner.first.accountEmail;
                imageUrl = owner.first.imageUrl;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                              color: Color(0xff398E7F),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(40.0),
                                bottomRight: Radius.circular(40.0),
                              )),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 190,
                                width: 160,
                                decoration: BoxDecoration(
                                    color: const Color(0xffD9D9D9),
                                    borderRadius: BorderRadius.circular(30)),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: (editImage == false)
                                        ? (owner.first.imageUrl == "")
                                            ? const Center(
                                                child: Icon(
                                                Icons.person,
                                                size: 30,
                                              ))
                                            : Image.network(
                                                owner.first.imageUrl,
                                                height: 190,
                                                width: 160,
                                                fit: BoxFit.fill)
                                        : Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            child: Image.file(
                                              image!,
                                              height: 190,
                                              width: 160,
                                              fit: BoxFit.fill,
                                            ),
                                          )),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
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
                                    color: const Color(0xff294243),
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
                            ],
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
                                height: 90,
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
                                          child: Text("First Name",
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
                                                controller: firtstName,
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: Text(
                                                    owner
                                                        .first.accountFirstName,
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
                                height: 90,
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
                                          child: Text("Last Name",
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
                                                controller: lastName,
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: Text(
                                                    owner.first.accountLastName,
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
                                height: 90,
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
                                          child: Text("Email",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16,
                                                  color: Colors.white)),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (editEmail == true) {
                                              editEmail = false;
                                            } else {
                                              editEmail = true;
                                            }

                                            setState(() {
                                              print(editEmail);
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
                                        child: (editEmail == true)
                                            ? AddBusinessInput(
                                                icon: Icons.person,
                                                hint: '',
                                                controller: email,
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: Text(
                                                    owner.first.accountEmail,
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
                                height: 90,
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
                                          child: Text("Phone Number",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16,
                                                  color: Colors.white)),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (editPhone == true) {
                                              editPhone = false;
                                            } else {
                                              editPhone = true;
                                            }

                                            setState(() {
                                              print(editPhone);
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
                                        child: (editPhone == true)
                                            ? AddBusinessInput(
                                                icon: Icons.person,
                                                hint: '',
                                                controller: phoneNumber,
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: Text(
                                                    owner.first
                                                        .accountPhoneNumber,
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

  Stream<List<Owner>> readOwner() {
    return FirebaseFirestore.instance
        .collection('Owner Accounts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['accountID'].toString().contains(user.uid))
            .map((doc) => Owner.fromJson(doc.data()))
            .toList());
  }
}
