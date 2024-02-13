import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'notifications.dart';
import 'dart:convert' as convert;

final EncryptedSharedPreferences _encryptedData =
EncryptedSharedPreferences();
const String _baseURL = 'https://pillremindermedminder.000webhostapp.com';

class AddPill extends StatefulWidget {
  const AddPill({super.key});

  @override
  State<AddPill> createState() => _AddPillState();
}

class _AddPillState extends State<AddPill> {
  final TextEditingController _pillname = TextEditingController();
  final TextEditingController _totalpills = TextEditingController();
  final TextEditingController _dosage = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TimeOfDay selectedTime = TimeOfDay.now();
  TimeOfDay selectedTime2 = TimeOfDay.now();
  bool option2 = false;

  bool _loading = false;

  void confirm(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    setState(() {
      _loading = false;
    });
    Navigator.of(context).pop();
  }
  @override
  void dispose() {
    _pillname.dispose();
    _totalpills.dispose();
    _dosage.dispose();
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
            'Add Pill',
            style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
          ),
          centerTitle: true,
          backgroundColor: Colors.lightBlue, // Add a subtle shadow
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
                    controller: _pillname,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter the pill name'),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please pill name';
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
                    controller: _totalpills,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter total number of pills'),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter the total number';
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
                    controller: _dosage,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter the dosage'),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter dosage';
                      } else {
                        return null; // Return null if the input is valid
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: [
                   const Text('SELECT PILL TIME: ',style: TextStyle(fontWeight: FontWeight.bold),),
                   ElevatedButton(onPressed: () async{
                     final TimeOfDay? timeOfDay = await showTimePicker(
                         context: context,
                         initialTime: selectedTime,
                         initialEntryMode: TimePickerEntryMode.dial
                     );
                     if(timeOfDay != null){
                       setState(() {
                         selectedTime = timeOfDay;
                       });
                     }
                   },style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                       child: Text('${selectedTime.hour}:${selectedTime.minute}',style: const TextStyle(color: Colors.lightBlue),)),
                 ],
               ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(width: w * 0.135,),
                    const Text('Other(optional): ',style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(width: w * 0.195,),
                    ElevatedButton(onPressed: () async{
                      final TimeOfDay? timeOfDay = await showTimePicker(
                          context: context,
                          initialTime: selectedTime2,
                          initialEntryMode: TimePickerEntryMode.dial
                      );
                      if(timeOfDay != null){
                        setState(() {
                          selectedTime2 = timeOfDay;
                          option2 = true;
                        });
                      }
                    },style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                        child: Text('${selectedTime2.hour}:${selectedTime2.minute}',style: const TextStyle(color: Colors.lightBlue),)),
                  ],
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
                       addPill(confirm, _pillname.text, _totalpills.text, _dosage.text,
                           selectedTime.hour.toString(), selectedTime.minute.toString(), selectedTime2.hour.toString()
                           , selectedTime2.minute.toString(), option2.toString());
                      }
                    },
                    child: const Text(
                      'Add Pill',
                      style: TextStyle(fontSize: 24, color: Colors.lightBlue),
                    )),
                Visibility(
                  visible: _loading,
                  child: const CircularProgressIndicator(),
                )
              ],
            ),
          ),
        )));
  }
}
void addPill(Function(String text) confirm, String name, String total, String dosage
    ,String hour1, String minute1,String hour2, String minute2, String option) async{
  try{
    String uid = await _encryptedData.getString('myKey');
    final response = await http.post(
        Uri.parse('$_baseURL/addPill.php'),
        headers: <String, String>{
          'Content-Type' : 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode(<String, String>{
          'uid':uid,
          'name': name,
          'total': total,
          'dosage': dosage,
          'hour1':hour1,
          'minute1':minute1,
          'hour2':hour2,
          'minute2':minute2,
          'option':option
        }))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
          final jsonResponse = convert.jsonDecode(response.body);
          var row = jsonResponse[0];
          int pid = int.parse(row['pid']);
          String temp = await _encryptedData.getString('notifOn');
          bool n = true;
          if(temp == '1'){
            n = true;
          }else{
            n = false;
          }
          String notNum = await _encryptedData.getString('notifNum');

          if(notNum == '3'){
            await NotificationService.showDailyNotificationAtHourMinute(
                id: pid,
                title: 'Pill Time!',
                body: 'It\'s time to take $name',
                hour: int.parse(hour1),
                minute: int.parse(minute1),
                notificationsEnabled: n);
            await NotificationService.showNotificationBeforeScheduledTime(
                id: int.parse('$uid$pid\4'),
                title: 'MedMinder',
                body: 'You will take $name after 1 hour',
                hour: int.parse(hour1),
                minute: int.parse(minute1),
                before: 1,
                notificationsEnabled: n);
            await NotificationService.showNotificationBeforeScheduledTime(
                id: int.parse('$uid$pid\8'),
                title: 'MedMinder',
                body: 'You will take $name after 2 hour',
                hour: int.parse(hour1),
                minute: int.parse(minute1),
                before: 2,
                notificationsEnabled: n);


            await NotificationService.showNotificationAtHourMinute(
                id: int.parse('$uid$pid\3'),
                title: 'Pill Missed!',
                body: 'You missed to take $name, Take it as soon as possible',
                hour: int.parse(hour1),
                minute: int.parse(minute1),
                delayHours: 1,
                notificationsEnabled: n
            );
            await NotificationService.showNotificationAtHourMinute(
                id: int.parse('$uid$pid\6'),
                title: 'Pill Missed!',
                delayHours: 2,
                body: 'You missed to take $name, Take it as soon as possible',
                hour: int.parse(hour1),
                minute: int.parse(minute1),
                notificationsEnabled: n
            );
            await NotificationService.showNotificationAtHourMinute(
                id: int.parse('$uid$pid\9'),
                title: 'Pill Missed!',
                body: 'You missed to take $name, Take it as soon as possible',
                hour: int.parse(hour1),
                delayHours: 3,
                minute: int.parse(minute1),
                notificationsEnabled: n
            );

            if (option == 'true'){


              await NotificationService.showDailyNotificationAtHourMinute(
                  id: int.parse('$uid$pid\1'),
                  title: 'Pill Time!',
                  body: 'It\'s time to take $name',
                  hour: int.parse(hour2),
                  minute: int.parse(minute2),
                  notificationsEnabled: n);
              await NotificationService.showNotificationBeforeScheduledTime(
                  id: int.parse('$uid$pid\5'),
                  title: 'MedMinder',
                  body: 'You will take $name after 1 hour',
                  hour: int.parse(hour2),
                  minute: int.parse(minute2),
                  before: 1,
                  notificationsEnabled: n);
              await NotificationService.showNotificationBeforeScheduledTime(
                  id: int.parse('$uid$pid\10'),
                  title: 'MedMinder',
                  body: 'You will take $name after 1 hour',
                  hour: int.parse(hour2),
                  minute: int.parse(minute2),
                  before: 2,
                  notificationsEnabled: n);

              await NotificationService.showNotificationAtHourMinute(
                  id: int.parse('$uid$pid\2'),
                  title: 'Pill Missed!',
                  body: 'You missed to take $name, Take it as soon as possible',
                  hour: int.parse(hour2),
                  delayHours: 1,
                  minute: int.parse(minute2),
                  notificationsEnabled: n);

              await NotificationService.showNotificationAtHourMinute(
                  id: int.parse('$uid$pid\7'),
                  title: 'Pill Missed!',
                  body: 'You missed to take $name, Take it as soon as possible',
                  hour: int.parse(hour2),
                  delayHours: 2,
                  minute: int.parse(minute2),
                  notificationsEnabled: n);
              await NotificationService.showNotificationAtHourMinute(
                  id: int.parse('$uid$pid\11'),
                  title: 'Pill Missed!',
                  body: 'You missed to take $name, Take it as soon as possible',
                  hour: int.parse(hour2),
                  delayHours: 3,
                  minute: int.parse(minute2),
                  notificationsEnabled: n);

            }

          }else if(notNum == '2'){

            await NotificationService.showDailyNotificationAtHourMinute(
                id: pid,
                title: 'Pill Time!',
                body: 'It\'s time to take $name',
                hour: int.parse(hour1),
                minute: int.parse(minute1),
                notificationsEnabled: n);
            await NotificationService.showNotificationBeforeScheduledTime(
                id: int.parse('$uid$pid\4'),
                title: 'MedMinder',
                body: 'You will take $name after 1 hour',
                hour: int.parse(hour1),
                minute: int.parse(minute1),
                before: 1,
                notificationsEnabled: n);


            await NotificationService.showNotificationAtHourMinute(
                id: int.parse('$uid$pid\3'),
                title: 'Pill Missed!',
                body: 'You missed to take $name, Take it as soon as possible',
                hour: int.parse(hour1),
                delayHours: 1,
                minute: int.parse(minute1),
                notificationsEnabled: n
            );
            await NotificationService.showNotificationAtHourMinute(
                id: int.parse('$uid$pid\6'),
                title: 'Pill Missed!',
                body: 'You missed to take $name, Take it as soon as possible',
                hour: int.parse(hour1),
                delayHours: 2,
                minute: int.parse(minute1),
                notificationsEnabled: n
            );


            if (option == 'true'){


              await NotificationService.showDailyNotificationAtHourMinute(
                  id: int.parse('$uid$pid\1'),
                  title: 'Pill Time!',
                  body: 'It\'s time to take $name',
                  hour: int.parse(hour2),
                  minute: int.parse(minute2),
                  notificationsEnabled: n);
              await NotificationService.showNotificationBeforeScheduledTime(
                  id: int.parse('$uid$pid\5'),
                  title: 'MedMinder',
                  body: 'You will take $name after 1 hour',
                  hour: int.parse(hour2),
                  minute: int.parse(minute2),
                  before: 1,
                  notificationsEnabled: n);

              await NotificationService.showNotificationAtHourMinute(
                  id: int.parse('$uid$pid\2'),
                  title: 'Pill Missed!',
                  body: 'You missed to take $name, Take it as soon as possible',
                  hour: int.parse(hour2),
                  delayHours: 1,
                  minute: int.parse(minute2),
                  notificationsEnabled: n);

              await NotificationService.showNotificationAtHourMinute(
                  id: int.parse('$uid$pid\7'),
                  title: 'Pill Missed!',
                  body: 'You missed to take $name, Take it as soon as possible',
                  hour: int.parse(hour2),
                  delayHours: 2,
                  minute: int.parse(minute2),
                  notificationsEnabled: n);

            }

          }else{



            await NotificationService.showDailyNotificationAtHourMinute(
                id: pid,
                title: 'Pill Time!',
                body: 'It\'s time to take $name',
                hour: int.parse(hour1),
                minute: int.parse(minute1),
                notificationsEnabled: n);

            await NotificationService.showNotificationAtHourMinute(
                id: int.parse('$uid$pid\3'),
                title: 'Pill Missed!',
                body: 'You missed to take $name, Take it as soon as possible',
                hour: int.parse(hour1),
                delayHours: 1,
                minute: int.parse(minute1),
                notificationsEnabled: n
            );
            if (option == 'true') {
              await NotificationService.showDailyNotificationAtHourMinute(
                  id: int.parse('$uid$pid\1'),
                  title: 'Pill Time!',
                  body: 'It\'s time to take $name',
                  hour: int.parse(hour2),
                  minute: int.parse(minute2),
                  notificationsEnabled: n);
              await NotificationService.showNotificationAtHourMinute(
                  id: int.parse('$uid$pid\2'),
                  title: 'Pill Missed!',
                  body: 'You missed to take $name, Take it as soon as possible',
                  hour: int.parse(hour2),
                  delayHours: 1,
                  minute: int.parse(minute2),
                  notificationsEnabled: n);
            }

          }




























      confirm('Pill added successfully!');
    }
  }catch(e){
      confirm('connection error');
  }
}
