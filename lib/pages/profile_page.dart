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
    required String ownerName,
    required String resName,
    required String address,
    required String foodType,
  }) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection("restaurant").doc(globalDocId).update({
      "ownerName": ownerName,
      "restaurantName": resName,
      "address": address,
      "foodType": foodType,
    });

    getRestaurantUser();
  }

  String imageURLStore = "";

  uploadImage() async {
    // from image picker package
    final ImagePicker picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);

    if (img == null) {
      Navigator.pop(context);
    } else {
      File file = File(img.path);

      // from firebase Storage image
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child(
        "restaurant/${DateTime.now().millisecondsSinceEpoch}.jpg",
      );

      try {
        imageRef.putFile(file).then((p0) async {
          final newImageURL = imageRef.getDownloadURL();

          imageURLStore = await newImageURL;

          Future.delayed(Duration(seconds: 1), () {
            updateImage();
          });
        });
      } catch (e) {
        print(e);
      }
    }
  }

  updateImage() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore
        .collection("restaurant")
        .doc(globalDocId)
        .update({"imageURL": imageURLStore})
        .then((value) async {
          getData();
        });
  }

  getData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await firestore.collection("restaurant").doc(globalDocId).get();

    Map<String, dynamic> finalData = snapshot.data() as Map<String, dynamic>;

    imageURL = finalData["imageURL"];

    setState(() {});
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
                                  onTap: () {
                                    uploadImage();
                                  },
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
                          TextEditingController nameEdit =
                              TextEditingController();
                          TextEditingController restaurantEdit =
                              TextEditingController();
                          TextEditingController addressEdit =
                              TextEditingController();
                          TextEditingController foodEdit =
                              TextEditingController();

                          return AlertDialog(
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: [
                                  TextFormField(
                                    controller: nameEdit,
                                    decoration: InputDecoration(
                                      hintText: "Owner Name",
                                    ),
                                  ),
                                  TextFormField(
                                    controller: restaurantEdit,
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
                                    controller: foodEdit,
                                    decoration: InputDecoration(
                                      hintText: "Food Type",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  updateOwnerProfile(
                                    ownerName: nameEdit.text,
                                    resName: restaurantEdit.text,
                                    address: addressEdit.text,
                                    foodType: foodEdit.text,
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
