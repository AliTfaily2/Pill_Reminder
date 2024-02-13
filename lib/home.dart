import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'signin.dart';
import 'showpills.dart';
import 'settings.dart';
import 'alert.dart';

const String _baseURL = 'https://pillremindermedminder.000webhostapp.com';
final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String username = '';

  void setUsername(String n) {
    setState(() {
      username = 'Welcome, $n!';
    });
  }

  void displayStatus(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void confirm(bool success) async {
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error Fetching User Data!')));
    }
  }

  @override
  void initState() {
    getUserData(confirm, setUsername);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MedMinder',
          style: TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 5),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
              onPressed: () {
                _encryptedData.remove('myKey').then((success) {
                  _encryptedData.remove('email');
                  _encryptedData.remove('name');
                  _encryptedData.remove('notifOn');
                  _encryptedData.remove('notifNum');
                  if (success) {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SignIn()));
                  } else {
                    displayStatus('Logout failed');
                  }
                });
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              )),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.05,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 25,
                ),
                Text(
                  username,
                  style: const TextStyle(
                      fontSize: 23,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey),
                ),
              ],
            ),
            SizedBox(
              height: height * 0.07,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ShowPills()));
              },
              child: Container(
                height: height * 0.15,
                width: width * 0.9,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: const DecorationImage(
                        image: AssetImage('assets/pills.jpg'),
                        fit: BoxFit.cover)),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 25,
                    ),
                    Text(
                      'PILLS',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: height * 0.05,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context)=>const Alerts())
                );
              },
              child: Container(
                height: height * 0.15,
                width: width * 0.9,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: const DecorationImage(
                        image: AssetImage('assets/notification.jpg'),
                        fit: BoxFit.cover)),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 25,
                    ),
                    Text(
                      'ALERTS',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: height * 0.05,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context)=> const AppSettings())
                );
              },
              child: Container(
                height: height * 0.15,
                width: width * 0.9,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: const DecorationImage(
                        image: AssetImage('assets/settings.jpg'),
                        fit: BoxFit.cover)),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 25,
                    ),
                    Text(
                      'SETTINGS',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          color: Colors.white),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

void getUserData(
    Function(bool success) confirm, Function(String n) setName) async {
  try {
    Future.delayed(const Duration(seconds: 1), () async{
      String uid = await _encryptedData.getString('myKey');
    final response = await http
        .post(Uri.parse('$_baseURL/getUserData.php'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8'
            },
            body: convert.jsonEncode(<String, String>{'uid': uid}))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      var row = jsonResponse[0];
      _encryptedData.setString('email', row['email']);
      _encryptedData.setString('name',  row['name']);
      _encryptedData.setString('notifOn', row['notif']);
      _encryptedData.setString('notifNum', row['notifNum']);
      setName(row['name']);
    }
    });
  } catch (e) {
    confirm(false);
  }
}
