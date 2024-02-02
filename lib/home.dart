import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'signin.dart';

const String _baseURL = 'https://pillremindermedminder.000webhostapp.com';
final EncryptedSharedPreferences _encryptedData =
EncryptedSharedPreferences();


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String username = '';

  void displayStatus(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
  void updateName(String name) {
    setState(() {
      username = 'Welcome, $name!';
    });
  }

  @override
  void initState() {
    getUsername(updateName, displayStatus);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedMinder', style: TextStyle(fontSize: 30,color: Colors.white,fontWeight: FontWeight.bold,letterSpacing: 5),),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(onPressed: () {
            _encryptedData.remove('myKey').then((success) {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SignIn())
              );
            });
          }, icon: const Icon(Icons.logout,color: Colors.white,)),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: height*0.05,),
            Row(
              children: [
                SizedBox(width: 25,),
                Text(username, style: TextStyle(fontSize: 23,letterSpacing: 3,fontWeight: FontWeight.w500,color: Colors.blueGrey),),
              ],
            ),
            SizedBox(height: height*0.07,),
            GestureDetector(onTap:(){},child: Container(
              height: height * 0.15,
              width: width * 0.9,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: const DecorationImage(
                      image: AssetImage('assets/pills.jpg'),
                      fit: BoxFit.cover
                  )
              ),
              child: const Row(
                children: [
                  SizedBox(width: 25,),
                  Text('PILLS',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 36,color: Colors.white),)
                ],
              ),
            ),),
            SizedBox(height: height*0.1,),
            GestureDetector(onTap:(){},child: Container(
              height: height * 0.15,
              width: width * 0.9,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: const DecorationImage(
                      image: AssetImage('assets/notification.jpg'),
                      fit: BoxFit.cover
                  )
              ),
              child: const Row(
                children: [
                  SizedBox(width: 25,),
                  Text('ALERTS',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 36,color: Colors.white),)
                ],
              ),
            ),)
          ],
        ),
      ),
    );
  }
}
void getUsername(Function(String name) updateName,
    Function(String text) displayStatus) async {
  try {
    String userID = await _encryptedData.getString('myKey');
    final response = await http
        .post(Uri.parse('$_baseURL/getUsername.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: convert.jsonEncode(<String, String>{'uid': userID}))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      var row = jsonResponse[0];
      updateName(row['name']);
    }
  } catch (e) {
    displayStatus('Failed to set username');
  }
}