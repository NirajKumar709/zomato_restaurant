import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
        title: Text("Restaurant Side"),
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
              child: Icon(Icons.person),
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
