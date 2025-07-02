import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zomato_restaurant/main.dart';
import 'package:zomato_restaurant/pages/delivery_patner.dart';
import 'package:zomato_restaurant/pages/profile_page.dart';

import '../auth/sing_in.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  signOut() async {
    await FirebaseAuth.instance.signOut().then((value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SingIn()),
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getAppBarData();
    getItems();
    super.initState();
  }

  Map<String, dynamic> dataStore = {};

  Stream<Map<String, dynamic>> getAppBarData() async* {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await firestore.collection("restaurant").doc(globalDocId).get();

    Map<String, dynamic> finalData = snapshot.data() as Map<String, dynamic>;

    dataStore = finalData;

    setState(() {});
  }

  TextEditingController foodName = TextEditingController();
  TextEditingController foodPrice = TextEditingController();

  String docId = "";

  foodItemCreate({required String foodName, required String foodPrice}) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final childFire =
        firestore
            .collection("restaurant")
            .doc(globalDocId)
            .collection("restaurant_items")
            .doc();

    docId = childFire.id;

    final docFire = childFire.set({
      "foodName": foodName,
      "foodPrice": foodPrice,
      "imageURL": itemsUrl,
      "docId": docId,
    }, SetOptions(merge: true));
  }

  List<DocumentSnapshot> dataGet = [];

  getItems() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot =
        await firestore
            .collection("restaurant")
            .doc(globalDocId)
            .collection("restaurant_items")
            .get();

    dataGet.addAll(snapshot.docs);

    setState(() {});
  }

  String itemsUrl = "";

  imageItems() async {
    final ImagePicker picker = ImagePicker();
    final pickedImg = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImg == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Select a image")));
    } else {
      File file = File(pickedImg.path);

      final storageRef = FirebaseStorage.instance.ref();
      final childRef = storageRef.child(
        "Restaurant_items/$globalDocId${DateTime.now().millisecondsSinceEpoch}.jpg",
      );

      await childRef.putFile(file).then((value) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Image upload Successfully")));
      });
      final downloadURL = childRef.getDownloadURL();

      itemsUrl = await downloadURL;
    }
  }

  deleteItem({required String id}) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore
        .collection("restaurant")
        .doc(globalDocId)
        .collection("restaurant_items")
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: IconButton(
              onPressed: () {
                signOut();
              },
              icon: Icon(Icons.logout),
            ),
          ),
        ],
        title: StreamBuilder<Map<String, dynamic>>(
          stream: getAppBarData(),
          builder: (context, snapshot) {
            return dataStore.isNotEmpty
                ? Row(
                  spacing: 5,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(dataStore["imageURL"]),
                    ),
                    Expanded(
                      child: Text(
                        dataStore["restaurantName"],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
                : Center(child: CircularProgressIndicator());
          },
        ),

        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          spacing: 10,
          children: [
            TextFormField(
              controller: foodName,
              decoration: InputDecoration(
                hintText: "Food name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            TextFormField(
              controller: foodPrice,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Food Price",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                imageItems();
              },
              child: Text("Select food image"),
            ),
            ElevatedButton(
              onPressed: () {
                foodItemCreate(
                  foodName: foodName.text,
                  foodPrice: foodPrice.text,
                );
                foodName.clear();
                foodPrice.clear();

                dataGet.clear();
                getItems();
              },
              child: Text("Add Items"),
            ),
            Expanded(
              child:
                  dataGet.isNotEmpty
                      ? ListView.builder(
                        itemCount: dataGet.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> finalItems =
                              dataGet[index].data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(finalItems["foodName"]),
                            subtitle: Text(finalItems["foodPrice"]),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                finalItems["imageURL"],
                              ),
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder:
                                  (context) => [
                                    PopupMenuItem(
                                      child: Text("Delete"),
                                      onTap: () {
                                        deleteItem(id: finalItems["docId"]);

                                        dataGet.clear();
                                        getItems();
                                      },
                                    ),
                                  ],
                            ),
                          );
                        },
                      )
                      : Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: InkWell(
              child: Icon(Icons.delivery_dining),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeliveryPatner()),
                );
              },
            ),
            label: "Delivery Partner",
          ),
          BottomNavigationBarItem(
            icon: InkWell(
              child: CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(imageURL),
              ),
              // Icon(Icons.person),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
