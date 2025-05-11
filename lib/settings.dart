import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'pill.dart';
import 'notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'DatabaseHelper.dart';

const String _baseURL = 'https://pillremindermedminder.000webhostapp.com';
final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  String name = '';
  String email = '';
  int notifNum = 3;
  bool notif = true;

  void getCredentials() async {
    String nameTemp = await _encryptedData.getString('name');
    String emailTemp = await _encryptedData.getString('email');
    String notifNumTemp = await _encryptedData.getString('notifNum');
    String notifTemp = await _encryptedData.getString('notifOn');
    setState(() {
      name = nameTemp;
      email = emailTemp;
      notifNum = int.parse(notifNumTemp);
      if (notifTemp == '1') {
        notif = true;
      } else {
        notif = false;
      }
    });
  }

  @override
  void initState() {
    getCredentials();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Settings',
          style: TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 5),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: Center(
        child: Column(
          children: [

            SizedBox(height: h * 0.1,),
            Row(
              children: [
                SizedBox(
                  width: w * 0.08,
                ),
                const Text('Username: ',
                    style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
                Text(name,
                    style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2))
              ],
            ),
            SizedBox(height: h * 0.03,),
            Row(
              children: [
                SizedBox(
                  width: w * 0.08,
                ),
                const Text('Email: ',
                    style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
                Text(email,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2))
              ],
            ),
            SizedBox(height: h * 0.03,),

            Row(
              children: [
                SizedBox(
                  width: w * 0.08,
                ),
                const Text('Notifications: ',
                    style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
                Checkbox(value: notif, onChanged: (bool? value){
                  setState(() {
                    notif = value as bool;
                    if(notif){
                      changeSetting('1',notifNum.toString());
                    }else{
                      changeSetting('0',notifNum.toString());
                    }

                  });
                }),

              ],
            ),
            SizedBox(height: h * 0.03,),

            Row(
              children: [
                SizedBox(
                  width: w * 0.08,
                ),
                const Text('number of notifications: ',
                    style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
              ],
            ),
            NumberPicker(
                minValue: 1,
                maxValue: 3,
                value: notifNum,
                axis: Axis.horizontal,
                onChanged:(value) {
                  String i;
                  if(notif){
                    i = '1';
                  }else{
                    i = '0';
                  }
                  setState(() {
                    notifNum = value;
                    changeSetting(i,notifNum.toString());
                  });
                }),
          ],
        ),
      ),
    );
  }
}
void getPills() async {
  try {
    String uid = await _encryptedData.getString('myKey');


    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> pillResults = await db.query(
      'pills',
      where: 'uid = ?',
      whereArgs: [int.tryParse(uid)],
    );
    await AwesomeNotifications().cancelAllSchedules();

      for (var row in pillResults) {
        Pill pill;
        if (row['hour2'] == null) {
          pill = Pill(
              row['pid'],
              row['pname'],
              int.parse(row['totalp']),
              int.parse(row['dosage']),
              int.parse(row['pillsTook']),
              row['hour1'],
              row['minute1'],
              '',
              '',
              false);
        } else {
          pill = Pill(
              row['pid'],
              row['pname'],
              int.parse(row['totalp']),
              int.parse(row['dosage']),
              int.parse(row['pillsTook']),
              row['hour1'],
              row['minute1'],
              row['hour2'],
              row['minute2'],
              true);
        }

        Future.delayed(const Duration(seconds: 4), () async{
        String temp = await _encryptedData.getString('notifOn');
        bool n = true;
        if(temp == '1'){
          n = true;
        }else{
          n = false;
        }
        String notNum = await _encryptedData.getString('notifNum');
        int p = int.parse(pill.pid);
        if(notNum == '3'){
          await NotificationService.showDailyNotificationAtHourMinute(
              id: p,
              title: 'Pill Time!',
              body: 'It\'s time to take ${pill.name}',
              hour: int.parse(pill.hour1),
              minute: int.parse(pill.minute1),
              notificationsEnabled: n);
          await NotificationService.showNotificationBeforeScheduledTime(
              id: int.parse('$uid$p\4'),
              title: 'MedMinder',
              body: 'You will take ${pill.name} after 1 hour',
              hour: int.parse(pill.hour1),
              minute: int.parse(pill.minute1),
              before: 1,
              notificationsEnabled: n);
          await NotificationService.showNotificationBeforeScheduledTime(
              id: int.parse('$uid$p\8'),
              title: 'MedMinder',
              body: 'You will take ${pill.name} after 2 hour',
              hour: int.parse(pill.hour1),
              minute: int.parse(pill.minute1),
              before: 2,
              notificationsEnabled: n);
          await NotificationService.showNotificationAtHourMinute(
              id: int.parse('$uid$p\3'),
              title: 'Pill Missed!',
              body: 'You missed to take ${pill.name}, Take it as soon as possible',
              hour: int.parse(pill.hour1),
              minute: int.parse(pill.minute1),
              delayHours: 1,
              notificationsEnabled: n
          );
          await NotificationService.showNotificationAtHourMinute(
              id: int.parse('$uid$p\6'),
              title: 'Pill Missed!',
              delayHours: 2,
              body: 'You missed to take ${pill.name}, Take it as soon as possible',
              hour: int.parse(pill.hour1),
              minute: int.parse(pill.minute1),
              notificationsEnabled: n
          );
          await NotificationService.showNotificationAtHourMinute(
              id: int.parse('$uid$p\9'),
              title: 'Pill Missed!',
              body: 'You missed to take ${pill.name}, Take it as soon as possible',
              hour: int.parse(pill.hour1),
              delayHours: 3,
              minute: int.parse(pill.minute1),
              notificationsEnabled: n
          );



          if (pill.option == true){
            await NotificationService.showDailyNotificationAtHourMinute(
                id: int.parse('$uid$p\1'),
                title: 'Pill Time!',
                body: 'It\'s time to take ${pill.name}',
                hour: int.parse(pill.hour2),
                minute: int.parse(pill.minute2),
                notificationsEnabled: n);
            await NotificationService.showNotificationBeforeScheduledTime(
                id: int.parse('$uid$p\5'),
                title: 'MedMinder',
                body: 'You will take ${pill.name} after 1 hour',
                hour: int.parse(pill.hour2),
                minute: int.parse(pill.minute2),
                before: 1,
                notificationsEnabled: n);
            await NotificationService.showNotificationBeforeScheduledTime(
                id: int.parse('$uid$p\10'),
                title: 'MedMinder',
                body: 'You will take ${pill.name} after 1 hour',
                hour: int.parse(pill.hour2),
                minute: int.parse(pill.minute2),
                before: 2,
                notificationsEnabled: n);

            await NotificationService.showNotificationAtHourMinute(
                id: int.parse('$uid$p\2'),
                title: 'Pill Missed!',
                body: 'You missed to take ${pill.name}, Take it as soon as possible',
                hour: int.parse(pill.hour2),
                delayHours: 1,
                minute: int.parse(pill.minute2),
                notificationsEnabled: n);

            await NotificationService.showNotificationAtHourMinute(
                id: int.parse('$uid$p\7'),
                title: 'Pill Missed!',
                body: 'You missed to take ${pill.name}, Take it as soon as possible',
                hour: int.parse(pill.hour2),
                delayHours: 2,
                minute: int.parse(pill.minute2),
                notificationsEnabled: n);
            await NotificationService.showNotificationAtHourMinute(
                id: int.parse('$uid$p\11'),
                title: 'Pill Missed!',
                body: 'You missed to take ${pill.name}, Take it as soon as possible',
                hour: int.parse(pill.hour2),
                delayHours: 3,
                minute: int.parse(pill.minute2),
                notificationsEnabled: n);

          }

        }else if(notNum == '2'){

          await NotificationService.showDailyNotificationAtHourMinute(
              id: p,
              title: 'Pill Time!',
              body: 'It\'s time to take ${pill.name}',
              hour: int.parse(pill.hour1),
              minute: int.parse(pill.minute1),
              notificationsEnabled: n);
          await NotificationService.showNotificationBeforeScheduledTime(
              id: int.parse('$uid$p\4'),
              title: 'MedMinder',
              body: 'You will take ${pill.name} after 1 hour',
              hour: int.parse(pill.hour1),
              minute: int.parse(pill.minute1),
              before: 1,
              notificationsEnabled: n);

          await NotificationService.showNotificationAtHourMinute(
              id: int.parse('$uid$p\3'),
              title: 'Pill Missed!',
              body: 'You missed to take ${pill.name}, Take it as soon as possible',
              hour: int.parse(pill.hour1),
              delayHours: 1,
              minute: int.parse(pill.minute1),
              notificationsEnabled: n
          );
          await NotificationService.showNotificationAtHourMinute(
              id: int.parse('$uid$p\6'),
              title: 'Pill Missed!',
              body: 'You missed to take ${pill.name}, Take it as soon as possible',
              hour: int.parse(pill.hour1),
              delayHours: 2,
              minute: int.parse(pill.minute1),
              notificationsEnabled: n
          );
          if (pill.option == true){


            await NotificationService.showDailyNotificationAtHourMinute(
                id: int.parse('$uid$p\1'),
                title: 'Pill Time!',
                body: 'It\'s time to take ${pill.name}',
                hour: int.parse(pill.hour2),
                minute: int.parse(pill.minute2),
                notificationsEnabled: n);
            await NotificationService.showNotificationBeforeScheduledTime(
                id: int.parse('$uid$p\5'),
                title: 'MedMinder',
                body: 'You will take ${pill.name} after 1 hour',
                hour: int.parse(pill.hour2),
                minute: int.parse(pill.minute2),
                before: 1,
                notificationsEnabled: n);

            await NotificationService.showNotificationAtHourMinute(
                id: int.parse('$uid$p\2'),
                title: 'Pill Missed!',
                body: 'You missed to take ${pill.name}, Take it as soon as possible',
                hour: int.parse(pill.hour2),
                delayHours: 1,
                minute: int.parse(pill.minute2),
                notificationsEnabled: n);

            await NotificationService.showNotificationAtHourMinute(
                id: int.parse('$uid$p\7'),
                title: 'Pill Missed!',
                body: 'You missed to take ${pill.name}, Take it as soon as possible',
                hour: int.parse(pill.hour2),
                delayHours: 2,
                minute: int.parse(pill.minute2),
                notificationsEnabled: n);

          }

        }else{



          await NotificationService.showDailyNotificationAtHourMinute(
              id: p,
              title: 'Pill Time!',
              body: 'It\'s time to take ${pill.name}',
              hour: int.parse(pill.hour1),
              minute: int.parse(pill.minute1),
              notificationsEnabled: n);
          await NotificationService.showNotificationAtHourMinute(
              id: int.parse('$uid$p\3'),
              title: 'Pill Missed!',
              body: 'You missed to take ${pill.name}, Take it as soon as possible',
              hour: int.parse(pill.hour1),
              delayHours: 1,
              minute: int.parse(pill.minute1),
              notificationsEnabled: n
          );

          if (pill.option == true) {
            await NotificationService.showDailyNotificationAtHourMinute(
                id: int.parse('$uid$p\1'),
                title: 'Pill Time!',
                body: 'It\'s time to take ${pill.name}',
                hour: int.parse(pill.hour2),
                minute: int.parse(pill.minute2),
                notificationsEnabled: n);
            await NotificationService.showNotificationAtHourMinute(
                id: int.parse('$uid$p\2'),
                title: 'Pill Missed!',
                body: 'You missed to take ${pill.name}, Take it as soon as possible',
                hour: int.parse(pill.hour2),
                delayHours: 1,
                minute: int.parse(pill.minute2),
                notificationsEnabled: n);
          }

        }
      }
        );
      }

  } catch (e) {
    return;
  }
}
void changeSetting(String notif,String notifNum) async {
  try {
    String uid = await _encryptedData.getString('myKey');

    final db = await DatabaseHelper.instance.database;
    await db.update(
      'users',
      {
        'notif': int.parse(notif),
        'notifNum': int.parse(notifNum),
      },
      where: 'uid = ?',
      whereArgs: [uid],
    );
    _encryptedData.setString('notifOn', notif);
    _encryptedData.setString('notifNum', notifNum);
    getPills();
    }catch(e) {
    return;
  }
  }