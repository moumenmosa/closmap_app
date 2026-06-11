import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String subject;
  final String body;
  final String route;
  final Map<String, String> routeParams;
  final bool read;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.subject,
    required this.body,
    this.route = '',
    this.routeParams = const {},
    this.read = false,
    required this.createdAt,
  });

  factory NotificationItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return NotificationItem(
      id: doc.id,
      subject: d['subject'] ?? '',
      body: d['body'] ?? '',
      route: d['route'] ?? '',
      routeParams: Map<String, String>.from(
        (d['routeParams'] as Map?)?.map((k, v) => MapEntry('$k', '$v')) ?? {},
      ),
      read: d['read'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'subject': subject,
        'body': body,
        'route': route,
        'routeParams': routeParams,
        'read': read,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

class TransactionItem {
  final String id;
  final String userId;
  final String type;
  final String description;
  final int pointsDelta;
  final DateTime createdAt;

  const TransactionItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.pointsDelta,
    required this.createdAt,
  });

  factory TransactionItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return TransactionItem(
      id: doc.id,
      userId: d['userId'] ?? '',
      type: d['type'] ?? '',
      description: d['description'] ?? '',
      pointsDelta: (d['pointsDelta'] ?? 0) as int,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'type': type,
        'description': description,
        'pointsDelta': pointsDelta,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

class SubscriptionPlan {
  final String id;
  final String name;
  final int price;
  final int points;
  final String currency;
  final String description;
  final List<String> features;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.points,
    this.currency = 'SR',
    this.description = '',
    this.features = const [],
  });

  factory SubscriptionPlan.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return SubscriptionPlan(
      id: doc.id,
      name: d['name'] ?? doc.id,
      price: (d['price'] ?? 0) as int,
      points: (d['points'] ?? 0) as int,
      currency: d['currency'] ?? 'SR',
      description: d['description'] ?? '',
      features: List<String>.from(d['features'] ?? []),
    );
  }
}

class PointPackage {
  final String id;
  final int points;
  final int price;
  final String currency;

  const PointPackage({
    required this.id,
    required this.points,
    required this.price,
    this.currency = 'SR',
  });

  factory PointPackage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return PointPackage(
      id: doc.id,
      points: (d['points'] ?? 0) as int,
      price: (d['price'] ?? 0) as int,
      currency: d['currency'] ?? 'SR',
    );
  }
}
