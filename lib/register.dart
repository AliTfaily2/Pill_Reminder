import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

const String _baseURL = 'https://pillremindermedminder.000webhostapp.com';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _cpassword = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _loading = false;

  void confirm(String text){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    setState(() {
      _loading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose(){
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _cpassword.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Register Page',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.lightBlue,
        ),
        body: SingleChildScrollView(
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: h * 0.1,
                    ),
                    SizedBox(
                      width: w * 0.8,
                      child: TextFormField(
                        controller: _username,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter your username'),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter username';
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: w * 0.8,
                      child: TextFormField(
                        controller: _email,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9@._-]'))
                        ],
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter your email'),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter email';
                          } else if (!RegExp(
                              r'\b[A-Za-z0-9._]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
                              .hasMatch(value)) {
                            return 'Please enter a valid Email';
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: w * 0.8,
                      child: TextFormField(
                        controller: _password,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter your password'),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter password';
                          } else if (value.length <= 8) {
                            return 'Password must be longer than 8 characters';
                          } else if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
                            return 'Password must contain at least one letter';
                          } else {
                            return null; // Return null if the input is valid
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: w * 0.8,
                      child: TextFormField(
                        controller: _cpassword,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter your password again'),
                        validator: (String? value) {
                          if (value == null ||
                              value.isEmpty ||
                              _password.text.toString() != value) {
                            return 'passwords doesn\'t match';
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _loading = true;
                            });
                            registerUser(confirm,_username.text.toString(),_email.text.toString(),_password.text.toString());
                          }
                        },
                        child: Text(
                          'Register',
                          style: TextStyle(fontSize: 24, color: Colors.lightBlue),
                        )),
                    Visibility(visible: _loading, child: const CircularProgressIndicator(),)
                  ],
                ),
              ),
            )));
  }
}
void registerUser(Function(String text) confirm, String username, String email, String password) async{
  try{
    final response = await http.post(
        Uri.parse('$_baseURL/Register.php'),
        headers: <String, String>{
          'Content-Type' : 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode(<String, String>{
          'usr': username,
          'email': email,
          'pass': password
        }))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      confirm(response.body);
    }
  }catch(e){
    confirm('connection error');
  }
}
