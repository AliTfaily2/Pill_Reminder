import 'package:flutter/material.dart';
import 'signin.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Pill Reminder App',
      debugShowCheckedModeBanner: false,
      home: SignIn(),
    );
  }
}
