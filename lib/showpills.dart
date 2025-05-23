import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pill_reminder/pill_clicked.dart';
import 'dart:convert' as convert;
import 'add_pill.dart';
import 'pill.dart';
import 'DatabaseHelper.dart';

final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();
const String _baseURL = 'https://pillremindermedminder.000webhostapp.com';

List<Pill> _pills = [
  Pill('', '', 0, 0, 0, '', '', '', '', false),
  Pill('', '', 0, 0, 0, '', '', '', '', false),
  Pill('', '', 0, 0, 0, '', '', '', '', false),
  Pill('', '', 0, 0, 0, '', '', '', '', false),
  Pill('', '', 0, 0, 0, '', '', '', '', false),
  Pill('', '', 0, 0, 0, '', '', '', '', false),
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
  final int index;

  const Buttons({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return _pills[index].totalPills != 0
        ? GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PillClick(),
                  settings: RouteSettings(arguments: _pills[index])));
            },
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
                    SizedBox(
                      height: h * 0.012,
                    ),
                    Text(
                      _pills[index].name,
                      style: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold),
                    ),
                    _pills[index].dose == 1
                        ? Text(
                            '${_pills[index].dose} Pill',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          )
                        : Text(
                            '${_pills[index].dose} Pills',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                    _pills[index].option
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${_pills[index].hour1 == '0'? '00':_pills[index].hour1}:${_pills[index].minute1 == '0' ? '00' : _pills[index].minute1}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Text(
                                '${_pills[index].hour2 == '0'? '00':_pills[index].hour2}:${_pills[index].minute2 == '0' ? '00' : _pills[index].minute2}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              )
                            ],
                          )
                        : Text(
                            '${_pills[index].hour1 == '0'? '00':_pills[index].hour1}:${_pills[index].minute1 == '0' ? '00' : _pills[index].minute1}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          )
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

    _pills.clear();

    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> pillResults = await db.query(
      'pills',
      where: 'uid = ?',
      whereArgs: [int.tryParse(uid)],
    );
      for (var row in pillResults) {
        if (row['hour2'] == null) {
          Pill p = Pill(
              row['pid'].toString(),
              row['pname'].toString(),
              row['totalp'],
              row['dosage'],
              row['pillsTook'],
              row['hour1'].toString(),
              row['minute1'].toString(),
              '',
              '',
              false);
          _pills.add(p);
        } else {
          Pill p = Pill(
              row['pid'].toString(),
              row['pname'].toString(),
              row['totalp'],
              row['dosage'],
              row['pillsTook'],
              row['hour1'].toString(),
              row['minute1'].toString(),
              row['hour2'].toString(),
              row['minute2'].toString(),
              true);
          _pills.add(p);
        }
      }
      for (var x = _pills.length; x < 6; x++) {
        _pills.add(
          Pill('', '', 0, 0, 0, '', '', '', '', false),
        );
      }
      refresh();

  } catch (e) {
    print(e);
    confirm('connection error');
  }
}
