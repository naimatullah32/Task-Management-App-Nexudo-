import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton pattern (taake poori app mein ek hi instance rahay)
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // 🔥 FIX: Android 13+ ke liye Permission Request (Ye add karein)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Notification Details (Branded Look & Feel)
  NotificationDetails _notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'nexudo_channel', // Channel ID
        'Nexudo Notifications', // Channel Name
        channelDescription: 'Task reminders and productivity alerts',
        importance: Importance.max,
        priority: Priority.high,
        color: Color(0xff7C6FFF), // Aapka primary purple color!
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  // ─────────────────────────────────────────────
  // 1. TASK DUE TOMORROW (Pre-planned Alert)
  // ─────────────────────────────────────────────
  Future<void> scheduleTaskReminder(int id, String title, DateTime dueDate) async {
    // Notification theek 1 din pehle subah 9 baje aayegi
    final scheduleTime = dueDate.subtract(const Duration(days: 1));

    // Agar time guzar chuka hai toh schedule na karein
    if (scheduleTime.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Task Due Tomorrow 📌',
      "Don't forget to complete '$title' by tomorrow. Keep up the momentum!",
      tz.TZDateTime.from(scheduleTime, tz.local),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ─────────────────────────────────────────────
  // 2. STREAK BREAK WARNING (Daily 8 PM Alert)
  // ─────────────────────────────────────────────
  Future<void> scheduleStreakWarning() async {
    // Har roz raat 8 baje check karega
    var now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0); // 8:00 PM

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      999, // Specific ID for streak
      'Your Streak is at Risk! 🔥',
      "Complete at least one task today to keep your streak alive. You've got this!",
      scheduledDate,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Daily repeat at 8 PM
    );
  }

  // ─────────────────────────────────────────────
  // 3. INACTIVITY ALERT (We miss you)
  // ─────────────────────────────────────────────
  Future<void> scheduleInactivityReminder() async {
    // Pehle purana inactivity reminder cancel karein
    await flutterLocalNotificationsPlugin.cancel(888);

    // Agar user 3 din tak app na khole
    final scheduleTime = DateTime.now().add(const Duration(days: 3));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      888, // Specific ID for inactivity
      'We miss your focus 🎯',
      "It's been a few days. Let's crush some tasks and get back on track!",
      tz.TZDateTime.from(scheduleTime, tz.local),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Jab task complete ho jaye toh aaj ki streak warning cancel kar dein
  Future<void> cancelStreakWarning() async {
    await flutterLocalNotificationsPlugin.cancel(999);
  }

  // ─────────────────────────────────────────────
  // 🧪 INSTANT TEST NOTIFICATION
  // ─────────────────────────────────────────────
  Future<void> showTestNotification() async {
    await flutterLocalNotificationsPlugin.show(
      1001, // Random ID
      'Nexudo is Live! 🚀',
      'If you see this, your notifications are working perfectly.',
      _notificationDetails(),
    );
  }
}