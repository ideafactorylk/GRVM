import 'dart:async';
import 'package:flutter/material.dart';
import 'package:idea_factory/timer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import './providers/products_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:idea_factory/select_product.dart';

class BarCodeScan extends StatefulWidget {
  final productType;
  BarCodeScan(this.productType);
  @override
  _BarCodeScanState createState() => _BarCodeScanState();
}

class _BarCodeScanState extends State<BarCodeScan> {
  bool barcodeButtonEnable = false;
  DatabaseReference _barcodeEnable;
  StreamSubscription<Event> _barcodeEnableSubscription;

  DatabaseReference _barcodeButtonEnable;
  StreamSubscription<Event> _barcodeButtonEnableSubscription;
  String title;

  @override
  void dispose() {
    super.dispose();
    _barcodeEnableSubscription.cancel();
    _barcodeButtonEnableSubscription.cancel();
  }

  @override
  void initState() {
    super.initState();
    this.title = widget.productType;
    _barcodeEnable =
        FirebaseDatabase.instance.reference().child('barcodeEnable');
    _barcodeButtonEnable =
        FirebaseDatabase.instance.reference().child('barcodeButtonEnabled');

    _barcodeButtonEnableSubscription =
        _barcodeButtonEnable.onValue.listen((Event event) {
      barcodeButtonEnable = event.snapshot.value;

      _barcodeButtonEnableSubscription.cancel();
      setState(() {});
    });
  }

  // void barcodeScan() {

  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => BarcodeScanning(title)),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Barcode Scan'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                tooltip: 'reset',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SelectProduct()),
                  );
                },
              ),
            ],
          ),
          body: Builder(builder: (BuildContext context) {
            return SafeArea(
              child: Container(
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Text('Looking for a bottle'),
                          SizedBox(
                            width: 250,
                            height: 50,
                            child: ElevatedButton(
                                onPressed: barcodeButtonEnable
                                    ? () => {
                                          _barcodeEnable.set(true),
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BarcodeScanning(title)),
                                          )
                                        }
                                    : null,
                                child: Text("Start barcode scan")),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            height: 50,
                            width: 250,
                            child: ElevatedButton(
                                onPressed: () => {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => TimeCount()),
                                      )
                                    },
                                child: Text('$title doesn\'t contain barcode')),
                          ),
                        ],
                      ),
                    ),
                    new Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 30),
                          Text('1. Instruction 1'),
                          Text('2. Instrcution 2'),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          })),
    );
  }
}

class BarcodeScanning extends StatefulWidget {
  final title;

  BarcodeScanning(this.title);

  @override
  _BarcodeScanningState createState() => _BarcodeScanningState();
}

class _BarcodeScanningState extends State<BarcodeScanning> {
  DatabaseReference _barcodeEnable;
  StreamSubscription<Event> _barcodeEnableSubscription;
  DatabaseReference _scanResults;
  StreamSubscription<Event> _scanResultsSubscription;

  @override
  void dispose() {
    super.dispose();
    _barcodeEnableSubscription.cancel();
    _scanResultsSubscription.cancel();
  }

  @override
  void initState() {
    super.initState();
    final dataz = Provider.of<Products>(context, listen: false);
    _scanResults = FirebaseDatabase.instance.reference().child('barcode');
    _barcodeEnable =
        FirebaseDatabase.instance.reference().child('barcodeEnable');

    _scanResultsSubscription = _scanResults.onValue.listen((Event event) {
      print(event.snapshot.value);
      if (event.snapshot.value != 0) {
        dataz.products.add(event.snapshot.value.toString());
        _scanResults.set(0);
        _barcodeEnable.set(false);
        _scanResultsSubscription.cancel();

        Future.delayed(Duration.zero, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TimeCount()),
          );
        });
      }
    });
    //data receive function from firebase
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              tooltip: 'reset',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SelectProduct()),
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Container(
            width: 200,
            height: 250,
            child: Column(
              children: [
                Text('Scaning Barcode'),
                SizedBox(height: 50),
                SpinKitWave(
                  color: Colors.blue,
                  size: 80.0,
                ),
                SizedBox(height: 50),
                Text('Please place your barcode infront of the sensor',
                    textAlign: TextAlign.center)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
