import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeliveryPatner extends StatefulWidget {
  const DeliveryPatner({super.key});

  @override
  State<DeliveryPatner> createState() => _DeliveryPatnerState();
}

class _DeliveryPatnerState extends State<DeliveryPatner> {
  List<DocumentSnapshot> dataStore = [];

  @override
  void initState() {
    // TODO: implement initState
    getDeliveryPartnerData();
    super.initState();
  }

  getDeliveryPartnerData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot =
        await firestore.collection("delivery_partner").get();

    dataStore.addAll(snapshot.docs);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Delivery Partner"), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child:
                dataStore.isNotEmpty
                    ? ListView.builder(
                      itemCount: dataStore.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> finalData =
                            dataStore[index].data() as Map<String, dynamic>;

                        return Card(
                          child: ListTile(
                            title: Text(finalData["name"]),
                            subtitle: Text(finalData["phone_number"]),
                            trailing: Text(finalData["address"]),
                          ),
                        );
                      },
                    )
                    : Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
