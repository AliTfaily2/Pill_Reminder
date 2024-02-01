import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedMinder', style: TextStyle(fontSize: 30,color: Colors.white,fontWeight: FontWeight.bold,letterSpacing: 5),),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: height*0.1,),
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
