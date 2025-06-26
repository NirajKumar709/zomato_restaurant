import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zomato_restaurant/auth/sing_in.dart';
import 'package:firebase_core/firebase_core.dart';

class Registration extends StatefulWidget {
  final String docId;

  const Registration({super.key, required this.docId});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  TextEditingController nameController = TextEditingController();
  TextEditingController restaurantName = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController foodType = TextEditingController();

  registrationDataStore({
    required String name,
    required String resName,
    required String address,
    required String food,
  }) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore
        .collection("restaurant")
        .doc(widget.docId)
        .set({
          "ownerName": name,
          "restaurantName": resName,
          "address": address,
          "foodType": food,
        })
        .then((value) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SingIn()),
          );
        });
  }

  uploadFile() async {}

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
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Enter Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
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
              controller: foodType,
              decoration: InputDecoration(
                hintText: "Food type",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                uploadFile();
              },
              child: Text("Select File Image"),
            ),
            ElevatedButton(
              onPressed: () {
                registrationDataStore(
                  name: nameController.text,
                  resName: restaurantName.text,
                  address: address.text,
                  food: foodType.text,
                );
              },
              child: Text("Register Now"),
            ),
          ],
        ),
      ),
    );
  }
}
