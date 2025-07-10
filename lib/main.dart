import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:zomato_restaurant/pages/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

String globalDocId = "";
List<String> imageURL = [];

GeoPoint? latitudeLongitude;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // for get latitude and longitude
  List<Location> locations = await locationFromAddress(
    "Gronausestraat 710, Enschede",
  );

  latitudeLongitude = GeoPoint(
    locations.first.latitude,
    locations.first.longitude,
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SplashScreen(), debugShowCheckedModeBanner: false);
  }
}
