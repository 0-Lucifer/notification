import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'addmed.dart';
import 'remindersettings.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Map<String, dynamic>> meds = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndLoad();
  }

  Future<void> _requestPermissionsAndLoad() async {
    await _requestNotificationPermission();
    if (Platform.isAndroid) {
      await Permission.scheduleExactAlarm.request();
    }
    await _loadReminders();
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isDenied && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Permission Needed'),
          content: const Text('Please allow notifications to receive medication reminders.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('meds');
    if (saved != null) {
      final List<dynamic> decoded = jsonDecode(saved);
      setState(() {
        meds = decoded.map((m) => {
          'name': m['name'],
          'instruction': m['instruction'] ?? '',
          'times': (m['times'] as List).map((t) => TimeOfDay(hour: t['hour'], minute: t['minute'])).toList(),
          'frequency': m['frequency'] ?? 'Every 6 hours',
          'duration': m['duration'] ?? 'Ongoing',
          'stopDate': m['stopDate'] != null ? DateTime.parse(m['stopDate']) : null,
        }).toList();
      });
      _filterExpiredReminders();
      await _rescheduleAllNotifications();
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(meds.map((m) => {
      'name': m['name'],
      'instruction': m['instruction'],
      'times': m['times'].map((TimeOfDay t) => {'hour': t.hour, 'minute': t.minute}).toList(),
      'frequency': m['frequency'],
      'duration': m['duration'],
      'stopDate': m['stopDate']?.toIso8601String(),
    }).toList());
    await prefs.setString('meds', encoded);
  }

  void _filterExpiredReminders() {
    final now = DateTime.now();
    meds.removeWhere((m) => m['stopDate'] != null && (m['stopDate'] as DateTime).isBefore(now));
    _saveReminders();
  }

  Future<void> _initializeNotifications() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    const AndroidInitializationSettings android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings ios = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(android: android, iOS: ios);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
    _initialized = true;
  }

  Future<void> _scheduleNotification(Map<String, dynamic> med, TimeOfDay time, int id) async {
    await _initializeNotifications();

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final stopDate = med['stopDate'] as DateTime?;
    if (stopDate != null && scheduledDate.isAfter(stopDate)) return;

    // Handle Android exact alarm permission
    AndroidScheduleMode scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.status;
      if (!status.isGranted) {
        scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle; // fallback
      }
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Medication Reminder',
      'Time to take ${med['name']}',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_channel',
          'Medication Reminders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(sound: 'default'),
      ),
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void _scheduleAllNotifications(Map<String, dynamic> med) {
    final times = med['times'] as List<TimeOfDay>;
    for (int i = 0; i < times.length; i++) {
      final id = 'med_${med['name']}_$i'.hashCode;
      _scheduleNotification(med, times[i], id);
    }
  }

  Future<void> _rescheduleAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    for (var med in meds) {
      _scheduleAllNotifications(med);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: meds.isEmpty
          ? const Center(child: Text('No reminders yet\nTap + to add one', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: meds.length,
        itemBuilder: (_, i) {
          final med = meds[i];
          return Dismissible(
            key: ValueKey(med),
            direction: DismissDirection.endToStart,
            background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white, size: 30)),
            onDismissed: (_) {
              setState(() => meds.removeAt(i));
              _saveReminders();
              _rescheduleAllNotifications();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${med['name']} deleted')));
            },
            child: InkWell(
              onTap: () async {
                final updated = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddMedScreen(initialData: med)));
                if (updated != null) {
                  setState(() => meds[i] = updated);
                  await _saveReminders();
                  await _rescheduleAllNotifications();
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal.withOpacity(0.3)),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.teal.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.medication, color: Colors.teal)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(med['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.teal),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ReminderSettingsScreen(med: med, onSave: (m) async {
                              setState(() => meds[i] = m);
                              await _saveReminders();
                              await _rescheduleAllNotifications();
                            })),
                          ),
                        ),
                      ],
                    ),
                    if ((med['instruction'] as String).isNotEmpty)
                      Padding(padding: const EdgeInsets.only(top: 4), child: Text('(${med['instruction']})', style: const TextStyle(color: Colors.grey))),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: (med['times'] as List<TimeOfDay>)
                          .map((t) => Chip(label: Text(t.format(context)), backgroundColor: Colors.teal.withOpacity(0.1)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, size: 32),
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMedScreen()));
          if (result != null) {
            setState(() => meds.add(result));
            await _saveReminders();
            await _rescheduleAllNotifications();
          }
        },
      ),
    );
  }
}