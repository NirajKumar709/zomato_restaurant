import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zomato_restaurant/auth/sing_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zomato_restaurant/main.dart';

class Registration extends StatefulWidget {
  final String docId;

  const Registration({super.key, required this.docId});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  TextEditingController restaurantName = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController foodType = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();

  registrationDataStore({
    required String restaurantName,
    required String address,
    required String phoneNumber,
  }) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore
        .collection("restaurant_profile")
        .doc(widget.docId)
        .set({
          "restaurantName": restaurantName,
          "address": address,
          "phoneNumber": phoneNumber,
          "foodType": selectedFood,
          "imageURL": restaurantImageURL,
          "restaurantId": widget.docId,
          "locations": latitudeLongitude,
        })
        .then((value) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SingIn()),
          );
        });
  }

  List<File> selectedImage = [];

  selectImage() async {
    // from image_picker Library
    final picker = ImagePicker().pickMultiImage();
    List<XFile> imagePick = await picker;

    if (imagePick.isNotEmpty) {
      for (var i = 0; i < imagePick.length; i++) {
        selectedImage.add(File(imagePick[i].path));

        print(selectedImage);
        print("________________________________________");
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Nothing is selected")));
    }
    setState(() {});
  }

  List<String> restaurantImageURL = [];

  storeImage() async {
    for (int j = 0; j < selectedImage.length; j++) {
      final storageRef = FirebaseStorage.instance.ref().child(
        "restaurant_profile/${widget.docId}${DateTime.now().millisecondsSinceEpoch}.jpg",
      );

      try {
        await storageRef.putFile(selectedImage[j]);
        final resImageUrl = storageRef.getDownloadURL();

        restaurantImageURL.add(await resImageUrl);

        print(restaurantImageURL.length);
        print("___________________________________________");
        print(resImageUrl);
      } catch (e) {
        print(e);
      }
    }
  }

  List<String> foodSelect = ["Veg", "Non-Veg"];
  String? selectedFood;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registration"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          spacing: 15,
          children: [
            TextFormField(
              controller: restaurantName,
              decoration: InputDecoration(
                hintText: "Enter Restaurant Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            TextFormField(
              controller: address,
              decoration: InputDecoration(
                hintText: "Address",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: phoneNumber,
              decoration: InputDecoration(
                hintText: "Phone Number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            DropdownButton(
              hint: Text('Select food type'),
              value: selectedFood,
              items:
                  foodSelect.map((String item) {
                    return DropdownMenuItem(value: item, child: Text(item));
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedFood = newValue!;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                selectImage();
              },
              child: Text("Upload photo"),
            ),
            Expanded(
              child:
                  selectedImage.isEmpty
                      ? Center(child: Text("Sorry nothing selected!!"))
                      : ListView.builder(
                        itemCount: selectedImage.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.file(
                                  selectedImage[index],
                                  width: 200,
                                  height: 200,
                                ),
                                Positioned(
                                  top: 25,
                                  right: 45,
                                  child: IconButton(
                                    color: Colors.white,
                                    icon: Icon(Icons.close, size: 30),
                                    onPressed: () {
                                      selectedImage.removeAt(index);

                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
            ElevatedButton(
              onPressed: () async {
                await storeImage();
                await registrationDataStore(
                  restaurantName: restaurantName.text,
                  address: address.text,
                  phoneNumber: phoneNumber.text,
                );
                restaurantName.clear();
                address.clear();
                phoneNumber.clear();
                selectedImage.clear();
                foodSelect.clear();
              },
              child: Text("Register Now"),
            ),
          ],
        ),
      ),
    );
  }
}
