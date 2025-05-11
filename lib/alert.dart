import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'DatabaseHelper.dart';

List<String> titles = [''];
List<String> messages = [''];

const String _baseURL = 'https://pillremindermedminder.000webhostapp.com';
final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();

class Alerts extends StatefulWidget {
  const Alerts({super.key});

  @override
  State<Alerts> createState() => _AlertsState();
}


class _AlertsState extends State<Alerts> {
  void confirm(String text) {
    setState(() {
    });
  }
  @override
  void initState() {
    getAlerts(confirm);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Alerts',
          style: TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 5),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(onPressed: (){
            setState(() {
            });
          }, icon: Icon(Icons.refresh))
        ],
      ),
      body: ListView.builder(
        itemCount: messages.length,
          padding: EdgeInsets.all(10),
          itemBuilder: (context,index){
        return Column(
          children: [
            SizedBox(height: h * 0.03,),
             Text(titles[index], style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                letterSpacing: 2) ),
            SizedBox(height: h * 0.01,),
            Text(messages[index],style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w300,
                letterSpacing: 2) )
          ],
        );
      }),
    );
  }
}
void getAlerts(Function(String text) confirm) async {
  try {
    String uid = await _encryptedData.getString('myKey');
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> alertResults = await db.query(
        'alerts',
        where: 'uid = ?',
        whereArgs: [int.parse(uid)],
        orderBy: 'created_at DESC' // optional, for latest alerts first
    );

    messages.clear();
    titles.clear();

    for (var row in alertResults) {
      titles.add(row['title'].toString());
      messages.add(row['message'].toString());
    }
    confirm('hello');
    print(titles);
    print(messages);
  } catch (e) {
    print('Error getting alerts: $e');
    return;
  }
}
