import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
    super.initState();
  }

  Map<String, dynamic> dataStore = {};

  getAppBarData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await firestore.collection("restaurant").doc(globalDocId).get();

    Map<String, dynamic> finalData = snapshot.data() as Map<String, dynamic>;

    dataStore = finalData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
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
        title:
            dataStore.isNotEmpty
                ? Row(
                  spacing: 10,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(dataStore["imageURL"]),
                    ),
                    Text(dataStore["restaurantName"]),
                  ],
                )
                : Center(child: CircularProgressIndicator()),
        centerTitle: true,
      ),
      body: Column(children: [Text("data")]),
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
