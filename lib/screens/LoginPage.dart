import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/menuUser.dart';
import 'package:flutter_application_1/api/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

enum LoginStatus { notSignIn, signIn }

class _LoginPageState extends State<LoginPage> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  String username, password;
  final _key = new GlobalKey<FormState>();
  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  var _autovalidate = false;

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      login();
    } else {
      setState(() {
        _autovalidate = true;
      });
    }
  }

  login() async {
    final response = await http.post(Uri.parse(BaseUrl.urlLogin),
        body: {"username": username, "password": password});
    final data = jsonDecode(response.body);
    int value = data['success'];
    String pesan = data['message'];
    //data user
    String usernameAPI = data['username'];
    String namaAPI = data['nama'];
    String userIdAPI = data['userid'];
    if (value == 1) {
      setState(() {
        _loginStatus = LoginStatus.signIn;
        savePref(value, usernameAPI, namaAPI, userIdAPI);
      });

      print(pesan);
    } else {
      print(pesan);
    }
  }

  savePref(
      int val, String usernameAPI, String namaAPI, String userIdAPI) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", val);
      preferences.setString("username", usernameAPI);
      preferences.setString("nama", namaAPI);
      preferences.setString("userid", userIdAPI);
      preferences.commit();
    });
  }

  var value;
  var level;
  var _nama;
  var _userid;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");
      level = preferences.getString("level");
      _nama = preferences.getString("nama");
      _userid = preferences.getString("userid");

      if (value == 1) {
        _loginStatus = LoginStatus.signIn;
      } else {
        _loginStatus = LoginStatus.notSignIn;
      }
    });
  }

  // sign out
  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", 0);
      preferences.setString("level", "");
      preferences.setString("nama", "");
      preferences.setString("userid", "");
      preferences.setString("level", "");
      preferences.commit();
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Scaffold(
          body: Form(
            key: _key,
            autovalidateMode: AutovalidateMode.always,
            // autovalidate: _autovalidate,
            child: ListView(
              padding: EdgeInsets.only(top: 90.0, left: 20.0, right: 20.0),
              children: <Widget>[
                Image.asset('asset/img/logo2.png', height: 60, width: 60),
                Text(
                  "Online Shop",
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.2,
                ),
                Text(
                  "Toko Online",
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.2,
                ),
                TextFormField(
                  validator: (a) {
                    if (a.isEmpty) {
                      return "Silahkan isi Username";
                    } else {
                      return null;
                    }
                  },
                  onSaved: (a) => username = a,
                  decoration: InputDecoration(labelText: "Username"),
                ),
                TextFormField(
                  obscureText: _secureText,
                  onSaved: (a) => password = a,
                  decoration: InputDecoration(
                      labelText: "Password",
                      suffixIcon: IconButton(
                          icon: Icon(_secureText
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: showHide)),
                ),
                MaterialButton(
                  padding: EdgeInsets.all(25.0),
                  color: Colors.lightBlue,
                  onPressed: () {
                    check();
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
        break;
      case LoginStatus.signIn:
        return MenuUser(signOut);
        break;
    }
  }
}
