import 'package:flutter/material.dart';
import 'package:idea_factory/verification.dart';
import 'barcode_scan.dart';
import 'providers/products_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class SelectProduct extends StatefulWidget {
  @override
  _SelectProductState createState() => _SelectProductState();
  var user;

  void initState() {
    FirebaseAuth auth = FirebaseAuth.instance;
    user = auth.currentUser.uid;
  }
}

class _SelectProductState extends State<SelectProduct> {
  @override
  void initState() {
    super.initState();
    final data = Provider.of<Products>(context, listen: false);
    data.updatefalse();
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<Products>(context, listen: false);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'log out',
              onPressed: () {
                FirebaseAuth.instance
                    .signOut()
                    .then((_) => {
                          data.bottleCount = 0,
                          data.cupCount = 0,
                          data.packetCount = 0,
                          data.currentBarCode = '',
                          data.currentProduct = '',
                        })
                    .then((_) => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Verification()),
                        ));
              },
            ),
          ],
          title: Text(
            'Select Product',
          ),
          centerTitle: true,
        ),
        body: Select(),
      ),
    );
  }
}

class Select extends StatefulWidget {
  @override
  _SelectState createState() => _SelectState();
}

class _SelectState extends State<Select> {
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> addPoints(context) async {
    final data = Provider.of<Products>(context, listen: false);
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    CollectionReference inputs =
        FirebaseFirestore.instance.collection('inputs');
    users
        .doc(auth.currentUser.phoneNumber)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        return inputs
            .add({
              'bottle_count': data.bottleCount,
              'cup_count': data.cupCount,
              'packet_count': data.packetCount,
              'bar_codes': data.products,
              'time': DateTime.now(),
              'user_id': auth.currentUser.uid
            })
            .then((value) => {})
            .then((_) => FirebaseAuth.instance.signOut())
            .then((_) => showDialog(
                    context: context,
                    builder: (context) {
                      Future.delayed(Duration(seconds: 5), () {
                        Navigator.of(context).pop(true);
                      });
                      return AlertDialog(
                        title: Text('Congrats'),
                        content: Text(
                            'You have binned ${data.bottleCount} bottles, ${data.cupCount} cups, ${data.packetCount} packets'),
                      );
                    })
                .then((value) => {
                      data.bottleCount = 0,
                      data.cupCount = 0,
                      data.packetCount = 0,
                      data.currentBarCode = '',
                      data.currentProduct = '',
                    })
                .then((value) => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Verification()),
                    )))
            .catchError((error) => print("Failed to add user: $error"));
      } else {
        print('Document does not exist on the database');

        return users
            .doc(auth.currentUser.phoneNumber)
            .set({
              'uid': auth.currentUser.uid,
              'phone_number': auth.currentUser.phoneNumber,
            })
            .then((value) => {
                  inputs
                      .add({
                        'bottle_count': data.bottleCount,
                        'cup_count': data.cupCount,
                        'packet_count': data.packetCount,
                        'bar_codes': data.products,
                        'time': DateTime.now(),
                        'user_id': auth.currentUser.uid
                      })
                      .then((value) => print("User Added"))
                      .catchError(
                          (error) => print("Failed to add user: $error"))
                })
            .then((_) => FirebaseAuth.instance.signOut())
            .then((value) => showDialog(
                    context: context,
                    builder: (context) {
                      Future.delayed(Duration(seconds: 5), () {
                        Navigator.of(context).pop(true);
                      });
                      return Container(
                        color: Colors.amber,
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: AlertDialog(
                            title: Text('Congrats'),
                            content: Text(
                                'You have binned ${data.bottleCount} bottles, ${data.cupCount} cups, ${data.packetCount} packets'),
                          ),
                        ),
                      );
                    })
                .then((value) => {
                      data.bottleCount = 0,
                      data.cupCount = 0,
                      data.packetCount = 0,
                      data.currentBarCode = '',
                      data.currentProduct = '',
                    })
                .then((value) => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Verification()),
                    )))
            .catchError((error) => print("Failed to add user: $error"));
      }
    });
  }

  DatabaseReference _openDoor;
  StreamSubscription<Event> _openDoorSubscription;

  @override
  void dispose() {
    super.dispose();

    _openDoorSubscription.cancel();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _openDoor = FirebaseDatabase.instance.reference().child('openDoor');
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<Products>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => {
                          data.currentProduct = 'bottle',
                          _openDoor.set('bottle'),
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BarCodeScan('bottle')))
                        },
                        child: Card(
                          elevation: 5,
                          child: Container(
                            height: 150,
                            width: 150,
                            // color: Colors.red,
                            child: Image.asset('images/soda.png'),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(data.bottleCount.toString(),
                          style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ),
              Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => {
                          data.currentProduct = 'packet',
                          _openDoor.set('packet'),
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BarCodeScan('packet')))
                        },
                        child: Card(
                          elevation: 5,
                          child: Container(
                            height: 150,
                            width: 150,
                            // color: Colors.red,
                            child: Image.asset('images/pack.png'),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(data.packetCount.toString(),
                          style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ),
              Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => {
                          data.currentProduct = 'cup',
                          _openDoor.set('cup'),
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BarCodeScan('cup')))
                        },
                        child: Card(
                          elevation: 5,
                          child: Container(
                            height: 150,
                            width: 150,
                            // color: Colors.red,
                            child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Image.asset('images/cups.png')),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(data.cupCount.toString(),
                          style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
              onPressed: () => {addPoints(context)}, child: Text(' Done')),
        ],
      ),
    );
  }
}
