import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:idea_factory/select_product.dart';

class Verification extends StatefulWidget {
  @override
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _otpController = TextEditingController();

  AuthCredential _phoneAuthCredential;
  String _verificationId;
  bool verified = false;

  @override
  void initState() {
    super.initState();
    if (auth.currentUser != null) {
      FirebaseAuth.instance.signOut();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SelectProduct()),
      );
    }
  }

  Future<void> _login() async {
    var error;
    User user;
    var snackBar;

    try {
      await FirebaseAuth.instance
          .signInWithCredential(this._phoneAuthCredential)
          .then((value) => user = value.user);
    } catch (e) {
      // print('Failed with error code: ${e.code}');
      // print(e.message);
      error = e.message;
      snackBar = SnackBar(content: Text(error));
    }

    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SelectProduct()),
      );
    } else {
      print(error);
      AlertDialog alert = AlertDialog(
        title: Text("Something went wrong"),
        content: Text(error),
        actions: [
          //your actions (I.E. a button)
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      _phoneNumberController.clear();
      _otpController.clear();
    }
  }

  // Future<void> _logout() async {
  //   print('log out');

  //   if (auth.currentUser != null) {
  //     try {
  //       await FirebaseAuth.instance.signOut();
  //     } catch (e) {
  //       _handleError(e);
  //     }
  //   }
  // }

  Future<void> _submitPhoneNumber() async {
    String phoneNumber =
        "+94" + int.parse(_phoneNumberController.text.trim()).toString();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (AuthCredential phoneAuthCredential) {},
      verificationFailed: (FirebaseAuthException e) {},
      timeout: const Duration(seconds: 60),
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-resolution timed out...
      },
      codeSent: (String verificationId, int resendToken) async {
        print('codeSent');
        this._verificationId = verificationId;

        // Update the UI - wait for the user to enter the SMS code
      },
    ); // All the callbacks are above
  }

  void _submitOTP() {
    /// get the `smsCode` from the user
    String smsCode = _otpController.text.toString().trim();
    this._phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: this._verificationId, smsCode: smsCode);

    _login();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Authenticate'),
          centerTitle: true,
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.logout),
            //   tooltip: 'Show Snackbar',
            //   onPressed: () {
            //     // _logout();
            //   },
            // ),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.all(40),
          // mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Phone Number   e.g 77 XXXXXXX',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Spacer(),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 50,
                    child: MaterialButton(
                      onPressed: _submitPhoneNumber,
                      child: Text('Submit'),
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 48),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'OTP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Spacer(),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 50,
                    child: MaterialButton(
                      onPressed: () => {
                        _submitOTP(),
                      },
                      child: Text('Verify'),
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
