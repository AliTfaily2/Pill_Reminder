import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'dart:convert' as convert;

import 'DatabaseHelper.dart';

const String _baseURL = 'https://pillremindermedminder.000webhostapp.com';
final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();

class NotificationService {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'high_importance_channel',
          channelKey: 'high_importance_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'high_importance_channel_group',
          channelGroupName: 'Group 1',
        )
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) async {
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  /// Use this method to detect when a new notification or a schedule is created
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationCreatedMethod');
  }

  /// Use this method to detect every time that a new notification is displayed
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    addAlert(receivedNotification.title.toString(),receivedNotification.body.toString());
  }

  /// Use this method to detect if the user dismissed a notification
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onDismissActionReceivedMethod');
  }

  /// Use this method to detect when the user taps on a notification or action button
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onActionReceivedMethod');
    final payload = receivedAction.payload ?? {};
    if (payload["navigate"] == "true") {}
  }

  static Future<void> showNotificationAtHourMinute({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    required final int hour,
    required final int minute,
    final int? delayHours,
    required final bool notificationsEnabled,
    required final int id
  }) async {
    if (!notificationsEnabled) {
      // Notifications are not enabled for this user
      return;
    }
    final now = DateTime.now();
    final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
    DateTime notificationTime;
    if (delayHours != null && delayHours > 0) {
      notificationTime = scheduledTime.add(Duration(hours: delayHours));
    } else {
      notificationTime = scheduledTime;
    }
    int intervalInMinutes = notificationTime.difference(now).inMinutes;

    if (intervalInMinutes < 6) {
      print('Interval is too short: $intervalInMinutes minutes. Setting interval to 6 minutes.');
      intervalInMinutes = 6; // Set interval to a valid value (6 minutes)
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'high_importance_channel',
        title: title,
        body: body,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
      ),
      actionButtons: actionButtons,
      schedule: NotificationInterval(
        interval: intervalInMinutes,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        preciseAlarm: true,
        repeats: true
      ),
    );
  }


  static Future<void> showDailyNotificationAtHourMinute({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    required final int hour,
    required final int minute,
    required final bool notificationsEnabled,
    required final int id
  }) async {
    if (!notificationsEnabled) {
      // Notifications are not enabled for this user
      return;
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'high_importance_channel',
        title: title,
        body: body,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
      ),
      actionButtons: actionButtons,
      schedule: NotificationCalendar(
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        hour: hour,
        minute: minute,
        repeats: true, // Set to true for daily repetition
      ),
    );
  }
  static Future<void> showNotificationBeforeScheduledTime({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    required final int hour,
    required final int minute,
    required final int before,
    required final bool notificationsEnabled,
    required final int id
  }) async {
    if (!notificationsEnabled) {
      return;
    }
    final now = DateTime.now();
    final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
    final notificationTime = scheduledTime.subtract(Duration(hours: before));
    int intervalInMinutes = notificationTime.difference(now).inMinutes;

    if (intervalInMinutes < 6) {
      print('Interval is too short: $intervalInMinutes minutes. Setting interval to 6 minutes.');
      intervalInMinutes = 6; // Set interval to a valid value (6 minutes)
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'high_importance_channel',
        title: title,
        body: body,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
      ),
      actionButtons: actionButtons,
      schedule: NotificationInterval(
        interval:intervalInMinutes,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        preciseAlarm: true,
      ),
    );
  }

}

void addAlert(String title, String msg) async {
  try {
    String uid = await _encryptedData.getString('myKey');
    final db = await DatabaseHelper.instance.database;

    await db.insert(
      'alerts',
      {
        'uid': int.parse(uid),
        'title': title,
        'message': msg,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  } catch (e) {
    print('Error adding alert: $e');
    return;
  }
}

