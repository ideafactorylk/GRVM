import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:idea_factory/providers/products_provider.dart';
import 'package:idea_factory/verification.dart';
import './loading.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Products()),
        ],
        child: MaterialApp(
          home: App(),
        )));
  });
}

class App extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          // return SomethingWentWrongScreen();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return Verification();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        // return Loading();
        return Loading();
      },
    );
  }
}
