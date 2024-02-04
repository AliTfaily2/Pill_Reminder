import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'signin.dart';
import 'showpills.dart';

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

  void setName()async{
    String temp =  await _encryptedData.getString('name');
    setState(() {
      username = 'Welcome, $temp!';
    });

  }

  @override
  void initState() {
    setName();
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
              if (success) {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignIn()));
              } else {
                displayStatus('Logout failed');
              }
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
                const SizedBox(width: 25,),
                Text(username, style: const TextStyle(fontSize: 23,letterSpacing: 3,fontWeight: FontWeight.w500,color: Colors.blueGrey),),
              ],
            ),
            SizedBox(height: height*0.07,),
            GestureDetector(onTap:(){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context)=> const ShowPills())
              );
            },child: Container(
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
