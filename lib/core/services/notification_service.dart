import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_item.dart';

class NotificationService {
  NotificationService(this._db);

  final FirebaseFirestore _db;
  final _local = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('notifications').doc(uid).collection('items');

  Stream<List<NotificationItem>> watch(String uid) {
    return _col(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(NotificationItem.fromDoc).toList());
  }

  Future<void> send({
    required String userId,
    required String subject,
    required String body,
    String route = '',
    Map<String, String> routeParams = const {},
    bool showLocal = true,
  }) async {
    final item = NotificationItem(
      id: '',
      subject: subject,
      body: body,
      route: route,
      routeParams: routeParams,
      createdAt: DateTime.now(),
    );
    await _col(userId).add(item.toMap());
    if (showLocal) {
      await _local.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        subject,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'closemap',
            'CloseMap',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }

  Future<void> markRead(String uid, String notificationId) async {
    await _col(uid).doc(notificationId).update({'read': true});
  }

  Future<int> unreadCount(String uid) async {
    final snap = await _col(uid).where('read', isEqualTo: false).get();
    return snap.size;
  }
}
