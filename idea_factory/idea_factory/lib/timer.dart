import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:idea_factory/select_product.dart';
import './providers/products_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class TimeCount extends StatefulWidget {
  @override
  _TimeCountState createState() => _TimeCountState();
}

class _TimeCountState extends State<TimeCount> {
  CountDownController _controller = CountDownController();
  DatabaseReference _counterRef;
  StreamSubscription<Event> _counterSubscription;

  @override
  void dispose() {
    super.dispose();
    _counterSubscription.cancel();
  }

  @override
  void initState() {
    super.initState();

    _counterRef = FirebaseDatabase.instance.reference().child('counter');

    _counterSubscription = _counterRef.onValue.listen((Event event) {
      //data receive function from firebase
      final dataz = Provider.of<Products>(context, listen: false);
      bool updated = dataz.updated;

      int value = event.snapshot.value;
      print(value);
      print(updated);
      // print(dataz.currentProduct);

      // convert data dex to char
      if (value == 1 && dataz.currentProduct == 'bottle' && !updated) {
        dataz.updatetrue();
        print('bottle in');
        dataz.bottleCounts();
        print(dataz.bottleCount);
        _counterRef.set(0);
        _counterSubscription.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SelectProduct()),
        );
        setState(() {});
        // if (dataz.currentBarCode != '') {
        //   dataz.products.add(dataz.currentBarCode);
        // }
      }
      if (value == 2 && dataz.currentProduct == 'packet' && !updated) {
        dataz.updatetrue();
        print('packets in');
        dataz.packetCounts();
        _counterRef.set(0);
        _counterSubscription.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SelectProduct()),
        );
        setState(() {});

        // if (dataz.currentBarCode != '') {
        //   dataz.products.add(dataz.currentBarCode);
        // }
      }

      if (value == 3 && dataz.currentProduct == 'cup' && !updated) {
        dataz.updatetrue();
        dataz.cupCounts();
        _counterRef.set(0);
        _counterSubscription.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SelectProduct()),
        );
        setState(() {});

        // if (dataz.currentBarCode != '') {
        //   dataz.products.add(dataz.currentBarCode);
        // }
      }
    }, onError: (Object o) {
      final DatabaseError error = o;
    });
  }

  // Future.delayed(const Duration(milliseconds: 100), () {

  // });

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
                setState(() {});
              },
            ),
          ],
        ),
        body: Center(
          child: Container(
            // color: Colors.amber,
            child: CircularCountDownTimer(
              duration: 30,
              initialDuration: 0,
              controller: _controller,
              width: MediaQuery.of(context).size.width / 3,
              height: MediaQuery.of(context).size.height / 3,
              ringColor: Colors.grey[300],
              ringGradient: null,
              fillColor: Colors.purpleAccent[100],
              fillGradient: null,
              backgroundColor: Colors.blue[500],
              backgroundGradient: null,
              strokeWidth: 3,
              strokeCap: StrokeCap.square,
              textStyle: TextStyle(
                  fontSize: 33.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              textFormat: CountdownTextFormat.S,
              isReverse: true,
              isReverseAnimation: false,
              isTimerTextShown: true,
              autoStart: true,
              onStart: () {
                // print('Countdown Started');
              },
              onComplete: () {
                _counterRef.set(0);
                _counterSubscription.cancel();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SelectProduct()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
