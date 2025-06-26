import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zomato_restaurant/main.dart';

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
        await firestore.collection("restaurant").doc(globalDocId).get();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile Update"), centerTitle: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title:
                dataStore.isNotEmpty
                    ? Text(dataStore["ownerName"] + " Profile Edit")
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
            child:
                dataStore.isNotEmpty
                    ? Column(
                      children: [
                        Text(
                          "Restaurant Owner Name: " + dataStore["ownerName"],
                        ),
                        Text("Restaurant Name: " + dataStore["restaurantName"]),
                        Text("Restaurant Address: " + dataStore["address"]),
                        Text("Restaurant Food Type: " + dataStore["foodType"]),
                      ],
                    )
                    : Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
