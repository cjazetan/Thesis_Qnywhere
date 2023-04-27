// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qnywhere/model/business.dart';
import 'package:qnywhere/user/userPage.dart';
import 'package:qnywhere/user/viewBusinessPage.dart';
import 'package:qnywhere/utilities/search_widget.dart';

class BusinessCategoryScreen extends StatefulWidget {
  final String category;
  const BusinessCategoryScreen({Key? key, required this.category})
      : super(key: key);

  @override
  State<BusinessCategoryScreen> createState() => _BusinessCategoryScreenState();
}

class _BusinessCategoryScreenState extends State<BusinessCategoryScreen> {
  String query = '';
  late List<Business> business;
  late List<Business> filteredBusiness;
  final User user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff398E7F),
      appBar: AppBar(
        flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
              Color(0xff398E7F),
              Color(0xff294243),
            ]))),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 24,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => UserPage(indexNo: 1, userId: user.uid)));
          },
        ),
        elevation: 0,
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Text(
              widget.category,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Business>>(
          stream: readBusiness(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something Went Wrong ${snapshot.error}');
            } else if (snapshot.hasData) {
              final business = snapshot.data!;
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSearch(),
                    const Padding(
                        padding: EdgeInsets.only(left: 30, bottom: 15),
                        child: Text("Select a Category",
                            style: TextStyle(
                                color: Color(0xff294243),
                                fontWeight: FontWeight.bold,
                                fontSize: 24))),
                    Flexible(
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: business.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return Center(
                              child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  height:
                                      MediaQuery.of(context).size.height * 0.35,
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  decoration: const BoxDecoration(
                                      color: Color(0xff294243),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20,
                                            left: 10,
                                            right: 15,
                                            bottom: 5),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: Image.network(
                                              business[index].businessImageUrl,
                                              width: 250,
                                              height: 150,
                                              fit: BoxFit.fill),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 52, top: 10, bottom: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                  business[index].businessName,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 17)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 30),
                                              child: GestureDetector(
                                                onTap: (() {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ViewBusinessPage(
                                                                businessId: business[
                                                                        index]
                                                                    .businessId,
                                                              )));
                                                }),
                                                child: Container(
                                                  width: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.arrow_forward,
                                                      size: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(left: 47),
                                            child: Icon(
                                              Icons.location_on,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            business[index].businessLocation,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                          )
                                        ],
                                      )
                                    ],
                                  )),
                            );
                          }),
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
    );
  }

  void searchBusiness(String query) {
    final business = filteredBusiness.where((business) {
      final nameLower = business.businessName.toLowerCase();
      final searchLower = query.toLowerCase();

      return nameLower.contains(searchLower);
    }).toList();

    setState(() {
      this.query = query;
      this.business = business;
    });
  }

  // fetch data from firebase collection where in a category of an Outlet matches to the specified categpory click by the user
  Stream<List<Business>> readBusiness() {
    return FirebaseFirestore.instance
        .collection('Business Accounts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((QueryDocumentSnapshot<Object?> element) =>
                element['businessType'].toString().contains(widget.category))
            .map((doc) => Business.fromJson(doc.data()))
            .toList());
  }

  Widget buildSearch() => SearchWidget(
        text: query,
        hintText: 'Search',
        onChanged: searchBusiness,
      );
}
