import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

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
  @override
  void initState() {
    getAlerts();
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
            getAlerts();
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
void getAlerts() async {
  try {
    String uid = await _encryptedData.getString('myKey');
    final response = await http
        .post(Uri.parse('$_baseURL/getAlerts.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode(<String, String>{
          'uid': uid,
        }))
        .timeout(const Duration(seconds: 5));
    messages.clear();
    titles.clear();
    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      for (var row in jsonResponse) {
        titles.add(row['title']);
        messages.add(row['message']);
      }
    }
  } catch (e) {
    return;
  }
}