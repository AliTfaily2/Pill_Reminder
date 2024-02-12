import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'home.dart';
import 'register.dart';

const String _baseURL = 'https://pillremindermedminder.000webhostapp.com';
final EncryptedSharedPreferences _encryptedData =
EncryptedSharedPreferences();

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _loading = false;

  void loginconfirm(bool success) async{
    if (success) {
      Navigator.of(context).pop();
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const Home()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Login Failed!')));
    }
    setState(() {
      _loading = false;
    });
  }

  void checkSavedData() async {
    _encryptedData.getString('myKey').then((String myKey) {
      if (myKey.isNotEmpty) {
        Navigator.of(context).pop();
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Home()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkSavedData();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Sign In Page',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.lightBlue, // Add a subtle shadow
        ),
        body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: h * 0.2,
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
                              r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
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
                        onPressed: _loading
                        ? null
                        : () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _loading = true;
                            });
                            checkLogin(loginconfirm,
                                _email.text.toString(), _password.text.toString());
                          }
                        },
                        child:  const Text(
                          'Sign in',
                          style: TextStyle(fontSize: 24, color: Colors.lightBlue),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    Visibility(
                      visible: _loading,
                      child: const CircularProgressIndicator(),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const Register()));
                      },
                      child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Don\'t have an account?',
                                style: TextStyle(
                                  color: Colors.black,
                                )),
                            Text(
                              ' Register now!',
                              style: TextStyle(color: Colors.lightBlue),
                            )
                          ]),
                    )
                  ],
                ),
              ),
            )));
  }
}

void checkLogin(
    Function(bool success) loginconfirm, String email, String password) async {
  try {
    final response = await http
        .post(Uri.parse('$_baseURL/login.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: convert
            .jsonEncode(<String, String>{'email': email, 'pass': password}))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      var row = jsonResponse[0];
      print('sign is ${row['uid']}');
      _encryptedData.setString('myKey', row['uid']);
      _encryptedData.setString('myName', row['name']);
      loginconfirm(true);
    }
  } catch (e) {
    loginconfirm(false);
  }
}
