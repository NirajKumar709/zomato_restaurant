import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zomato_restaurant/main.dart';
import 'package:zomato_restaurant/pages/home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    // TODO: implement initState
    getRestaurantUser();
    super.initState();
  }

  Map<String, dynamic> dataStore = {};

  getRestaurantUser() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await firestore.collection("restaurant_profile").doc(globalDocId).get();

    dataStore = snapshot.data() as Map<String, dynamic>;

    setState(() {});
  }

  updateOwnerProfile({
    required String resName,
    required String address,
    required String phoneNumber,
  }) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection("restaurant_profile").doc(globalDocId).update({
      "restaurantName": resName,
      "address": address,
      "phoneNumber": phoneNumber,
    });

    getRestaurantUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          spacing: 10,
          children: [
            CircleAvatar(radius: 15, backgroundImage: NetworkImage("imageURL")),
            Text("Profile Update"),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title:
                dataStore.isNotEmpty
                    ? Row(
                      spacing: 10,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(radius: 25),

                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: InkWell(
                                  onTap: () {},
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(dataStore["restaurantName"] + "Profile"),
                      ],
                    )
                    : Center(child: CircularProgressIndicator()),
            trailing: PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: Text("Edit"),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          TextEditingController restaurantNameEdit =
                              TextEditingController();
                          TextEditingController addressEdit =
                              TextEditingController();
                          TextEditingController phoneNumberEdit =
                              TextEditingController();

                          return AlertDialog(
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: [
                                  TextFormField(
                                    controller: restaurantNameEdit,
                                    decoration: InputDecoration(
                                      hintText: "Restaurant Name",
                                    ),
                                  ),
                                  TextFormField(
                                    controller: addressEdit,
                                    decoration: InputDecoration(
                                      hintText: "Address",
                                    ),
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: phoneNumberEdit,
                                    decoration: InputDecoration(
                                      hintText: "Phone",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  updateOwnerProfile(
                                    resName: restaurantNameEdit.text,
                                    address: addressEdit.text,
                                    phoneNumber: phoneNumberEdit.text,
                                  );
                                  dataStore.clear();
                                  Navigator.pop(context);
                                },
                                child: Text("Save"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ];
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Card(
              child:
                  dataStore.isNotEmpty
                      ? ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Restaurant: " + dataStore["restaurantName"]),
                            Text("Address: " + dataStore["address"]),
                          ],
                        ),
                        trailing: Text(dataStore["foodType"]),
                        leading: CircleAvatar(radius: 20),
                      )
                      : Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
