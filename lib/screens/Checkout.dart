import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Checkout extends StatefulWidget {
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  var loading = false;
  var loadingDetail = false;

  String idUsers;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idUsers = preferences.getString("userid");
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", 0);
      preferences.commit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          padding: EdgeInsets.only(top: 200.0, left: 20.0, right: 20.0),
          children: <Widget>[
            Center(
              child: Image.asset(
                'assets/img/checklist.png',
                width: 80.0,
                height: 80.0,
              ),
            ),
            Center(
              child: Text(
                "\nBerhasil Checkout!",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Center(
              child: RaisedButton(
                padding: EdgeInsets.only(left: 30.0, right: 30.0),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                color: Colors.green,
                child: Text(
                  "Transaksi Baru",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}
