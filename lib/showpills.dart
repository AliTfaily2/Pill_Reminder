import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'add_pill.dart';
import 'pill.dart';

final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();
const String _baseURL = 'https://pillremindermedminder.000webhostapp.com';

List<Pill> _pills = [
  Pill('', 0, 0, '', '', '', '', false),
  Pill('', 0, 0, '', '', '', '', false),
  Pill('', 0, 0, '', '', '', '', false),
  Pill('', 0, 0, '', '', '', '', false),
  Pill('', 0, 0, '', '', '', '', false),
  Pill('', 0, 0, '', '', '', '', false),
];

class ShowPills extends StatefulWidget {
  const ShowPills({super.key});

  @override
  State<ShowPills> createState() => _ShowPillsState();
}

class _ShowPillsState extends State<ShowPills> {
  void confirm(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getPills(confirm, refresh);
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Pills',
            style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
          ),
          centerTitle: true,
          backgroundColor: Colors.lightBlue, // Add a subtle shadow
        ),
        body: ListView.builder(
            itemCount: _pills.length,
            itemBuilder: (context, index) {
              return Column(children: [
                SizedBox(
                  height: h * 0.03,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Buttons(
                      index: index,
                    ),
                  ],
                ),
              ]);
            }));
  }
}

class Buttons extends StatelessWidget {
  int index;

  Buttons({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return _pills[index].totalPills != 0
        ? GestureDetector(
            onTap: () {},
            child: Container(
              height: h * 0.15,
              width: w * 0.8,
              decoration: BoxDecoration(
                gradient: const RadialGradient(radius: 1.5, colors: [
                  Colors.teal,
                  Colors.cyan,
                  Colors.lightBlue,
                ]),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: h*0.012,),
                    Text(_pills[index].name,style: const TextStyle(fontSize: 30,color: Colors.white,letterSpacing: 2,fontWeight: FontWeight.bold),),
                    _pills[index].dose == 1? Text('${_pills[index].dose} Pill',style: const TextStyle(fontSize: 18,color: Colors.white),)
                        :
                    Text('${_pills[index].dose} Pills',style: const TextStyle(fontSize: 18,color: Colors.white),),
                    _pills[index].option?Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${_pills[index].hour1}:${_pills[index].minute1}',style: TextStyle(color: Colors.white,fontSize: 16),),
                        const SizedBox(width: 30,),
                        Text('${_pills[index].hour2}:${_pills[index].minute2}',style: TextStyle(color: Colors.white,fontSize: 16),)
                      ],
                    ):
                        Text('${_pills[index].hour1}:${_pills[index].minute1}',style: TextStyle(color: Colors.white,fontSize: 16),)
                  ],
                ),
              ),
            ))
        : GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddPill()));
            },
            child: Container(
              height: h * 0.15,
              width: w * 0.8,
              decoration: BoxDecoration(
                gradient: const RadialGradient(radius: 1.5, colors: [
                  Colors.grey,
                  Colors.blueGrey,
                  Colors.black,
                ]),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 50,
              ),
            ));
  }
}

void getPills(Function(String text) confirm, Function() refresh) async {
  try {
    String uid = await _encryptedData.getString('myKey');
    final response = await http
        .post(Uri.parse('$_baseURL/getPills.php'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: convert.jsonEncode(<String, String>{
              'uid': uid,
            }))
        .timeout(const Duration(seconds: 5));
    _pills.clear();
    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      for (var row in jsonResponse) {
        if (row['hour2'] == null) {
          Pill p = Pill(
              row['pname'],
              int.parse(row['totalp']),
              int.parse(row['dosage']),
              row['hour1'],
              row['minute1'],
              '',
              '',
              false);
          _pills.add(p);
        } else {
          Pill p = Pill(
              row['pname'],
              int.parse(row['totalp']),
              int.parse(row['dosage']),
              row['hour1'],
              row['minute1'],
              row['hour2'],
              row['minute2'],
              true);
          _pills.add(p);
        }
      }
      for (var x = _pills.length; x < 6; x++) {
        _pills.add(
          Pill('', 0, 0, '', '', '', '', false),
        );
      }
      refresh();
    }
  } catch (e) {
    confirm('connection error');
  }
}
