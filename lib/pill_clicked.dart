import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:http/http.dart' as http;
import 'notifications.dart';
import 'dart:convert' as convert;
import 'pill.dart';

final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();
const String _baseURL = 'https://pillremindermedminder.000webhostapp.com';

class PillClick extends StatefulWidget {
  const PillClick({super.key});

  @override
  State<PillClick> createState() => _PillClickState();
}

class _PillClickState extends State<PillClick> {

  void confirm(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final pill = ModalRoute.of(context)!.settings.arguments as Pill;
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Pill',
          style: TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue, // Add a subtle shadow
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: h*0.1,),
            Text(pill.name,style: const TextStyle(
                fontSize: 30,
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
                letterSpacing: 5),
            ),
            SizedBox(height: h * 0.09,),
            Row(
              children: [
                SizedBox(width: w * 0.08,),
                const Text('Dose: ', style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                letterSpacing: 2) ),
                Text('${pill.dose.toString()} ${pill.dose > 1 ? 'Pills':'Pill'}',style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2) )
              ],
            ),
            SizedBox(height: h * 0.02,),
            Row(
              children: [
                SizedBox(width: w * 0.08,),
                const Text('Pills Took: ', style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2) ),
                Text('${pill.pillsTook.toString()}/${pill.totalPills.toString()}',style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2) )
              ],
            ),
            SizedBox(height: h * 0.02,),
            Row(
              children: [
                SizedBox(width: w * 0.08,),
                const Text('Schedule: ', style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2) ),
                Text('${pill.hour1 == '0'? '00':pill.hour1}:${pill.minute1 == '0' ? '00' : pill.minute1}',style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2) )
              ],
            ),
            SizedBox(height: h * 0.02,),
            Visibility(visible: pill.option,child: Row(
              children: [
                SizedBox(width: w * 0.08,),
                const Text('Schedule 2: ', style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2) ),
                Text('${pill.hour2 == '0'? '00':pill.hour2}:${pill.minute2 == '0' ? '00' : pill.minute2}',style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2) )
              ],
            ),),
            SizedBox(height: h * 0.05,),
            ElevatedButton(onPressed: (){
              takePill(confirm,pill.pillsTook,pill);
            }, child: const Text('Take Pill', style: TextStyle(color: Colors.blue,fontSize: 24),))



          ],
        ),
      ) // here will be a button to take the pill ,
    );
  }
}

void takePill(Function(String text) confirm, int pillsTook, Pill pill) async {
  try {
    String uid = await _encryptedData.getString('myKey');
    final response = await http
        .post(Uri.parse('$_baseURL/takePill.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode(<String, String>{
          'pid': pill.pid,
          'pt' : pillsTook.toString()
        }))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      int p = int.parse(pill.pid);

      await AwesomeNotifications().cancel(int.parse('$p'));
      await AwesomeNotifications().cancel(int.parse('$uid$p\1'));
      await AwesomeNotifications().cancel(int.parse('$uid$p\2'));
      await AwesomeNotifications().cancel(int.parse('$uid$p\3'));
      await AwesomeNotifications().cancel(int.parse('$uid$p\4'));
      await AwesomeNotifications().cancel(int.parse('$uid$p\5'));
      await AwesomeNotifications().cancel(int.parse('$uid$p\6'));
      await AwesomeNotifications().cancel(int.parse('$uid$p\7'));
      await AwesomeNotifications().cancel(int.parse('$uid$p\8'));
      await AwesomeNotifications().cancel(int.parse('$uid$p\9'));
      await AwesomeNotifications().cancel(int.parse('$uid$p\10'));
      await AwesomeNotifications().cancel(int.parse('$uid$p\11'));



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



        }

      }else{



        await NotificationService.showDailyNotificationAtHourMinute(
            id: p,
            title: 'Pill Time!',
            body: 'It\'s time to take ${pill.name}',
            hour: int.parse(pill.hour1),
            minute: int.parse(pill.minute1),
            notificationsEnabled: n);


        if (pill.option == true) {
          await NotificationService.showDailyNotificationAtHourMinute(
              id: int.parse('$uid$p\1'),
              title: 'Pill Time!',
              body: 'It\'s time to take ${pill.name}',
              hour: int.parse(pill.hour2),
              minute: int.parse(pill.minute2),
              notificationsEnabled: n);

        }

      }


      Future.delayed(const Duration(seconds: 10800), () async{
       if(notNum == '3'){
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
         if(pill.option == true){
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
         if(pill.option == true){
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
         await NotificationService.showNotificationAtHourMinute(
             id: int.parse('$uid$p\3'),
             title: 'Pill Missed!',
             body: 'You missed to take ${pill.name}, Take it as soon as possible',
             hour: int.parse(pill.hour1),
             delayHours: 1,
             minute: int.parse(pill.minute1),
             notificationsEnabled: n
         );
         if(pill.option == true){
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

      });
        confirm(response.body);
    }
  } catch (e) {
    confirm('connection error');
  }
}