import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'signin.dart';
import 'showpills.dart';
import 'settings.dart';
import 'alert.dart';
import 'DatabaseHelper.dart';

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
    await Future.delayed(const Duration(seconds: 1)); // mimic async wait

    String uid = await _encryptedData.getString('myKey');

    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );

    if (result.isNotEmpty) {
      final user = result.first;
      print(user['notif']);
      print(user['notifNum']);
      _encryptedData.setString('email', user['email'] as String);
      _encryptedData.setString('name',  user['username'] as String);
      _encryptedData.setString('notifOn', user['notif'].toString());
      _encryptedData.setString('notifNum', user['notifNum'].toString());
      setName(user['username'] as String);
      confirm(true);
    } else {
      confirm(false);
    }
  } catch (e) {
    confirm(false);
  }
}

