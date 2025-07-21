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
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SingIn()),
    );
  }

  @override
  void initState() {
    getAppBarData();
    getItems();
    super.initState();
  }

  Map<String, dynamic> dataStore = {};

  Future<void> getAppBarData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot snapshot = await firestore
        .collection("restaurant_profile")
        .doc(globalDocId)
        .get()
        .then((value) {
          setState(() {});
          return value;
        });

    Map<String, dynamic> finalData = snapshot.data() as Map<String, dynamic>;

    dataStore = finalData;

    return;
  }

  TextEditingController foodName = TextEditingController();
  TextEditingController foodPrice = TextEditingController();

  String docId = "";

  foodItemCreate({required String foodName, required String foodPrice}) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final childFire =
        firestore
            .collection("many_restaurant_item")
            .doc(globalDocId)
            .collection("restaurant_items")
            .doc();

    docId = childFire.id;

    final docFire = childFire.set(
      {
        "foodName": foodName,
        "foodPrice": foodPrice,
        "imageURL": foodImageURL,
        "docId": docId,
      },
      // SetOptions(merge: true),
    );
  }

  List<DocumentSnapshot> dataGet = [];

  getItems() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot =
        await firestore
            .collection("many_restaurant_item")
            .doc(globalDocId)
            .collection("restaurant_items")
            .get();

    dataGet.addAll(snapshot.docs);

    setState(() {});
  }

  File? selectedImage;

  imageItems() async {
    XFile? picker = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picker != null) {
      selectedImage = File(picker.path);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Nothing is selected")));
    }

    setState(() {});
  }

  String? foodImageURL = "";

  foodImagesURL() async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance.ref().child(
      "restaurant_items/${globalDocId}/$fileName.jpg",
    );

    try {
      if (selectedImage != null) {
        await storageRef.putFile(selectedImage!);
        final downloadURL = await storageRef.getDownloadURL();

        foodImageURL = downloadURL;

        print("Image uploaded: $downloadURL");
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("No image select")));
      }
    } catch (e) {
      print("Upload error: $e");
    }
  }

  deleteItem({required String id}) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore
        .collection("many_restaurant_item")
        .doc(globalDocId)
        .collection("restaurant_items")
        .doc(id)
        .delete();

    setState(() {});
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
        title: FutureBuilder(
          future: getAppBarData(),
          builder: (context, snapshot) {
            return Row(
              spacing: 10,
              children: [
                dataStore.isNotEmpty
                    ? CircleAvatar(radius: 18)
                    : Center(child: CircularProgressIndicator()),

                dataStore.isNotEmpty
                    ? Expanded(
                      child: Text(
                        dataStore["restaurantName"],
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                    : Center(child: CircularProgressIndicator()),
              ],
            );
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
            SizedBox(
              height: 85,
              child:
                  selectedImage == null
                      ? Text("No image selected")
                      : Stack(
                        children: [
                          Container(
                            height: 200,
                            width: 75,
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 32,
                            child: IconButton(
                              onPressed: () {
                                selectedImage = null;

                                setState(() {});
                              },
                              icon: Icon(Icons.close, size: 35),
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
            ),
            ElevatedButton(
              onPressed: () async {
                await foodImagesURL();
                foodItemCreate(
                  foodName: foodName.text,
                  foodPrice: foodPrice.text,
                );
                foodName.clear();
                foodPrice.clear();

                dataGet.clear();
                selectedImage = null;
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
              child: FutureBuilder(
                future: getAppBarData(),
                builder: (context, snapshot) {
                  return dataStore.isNotEmpty
                      ? CircleAvatar(radius: 15)
                      : Center(child: CircularProgressIndicator());
                },
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
