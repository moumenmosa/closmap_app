import 'package:cloud_firestore/cloud_firestore.dart';

class ExploringSpot {
  final String id;
  final String seekerId;
  final String name;
  final String locationText;
  final double lat;
  final double lng;
  final double radiusKm;
  final DateTime createdAt;

  const ExploringSpot({
    required this.id,
    required this.seekerId,
    required this.name,
    this.locationText = '',
    required this.lat,
    required this.lng,
    this.radiusKm = 5,
    required this.createdAt,
  });

  factory ExploringSpot.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return ExploringSpot(
      id: doc.id,
      seekerId: d['seekerId'] ?? '',
      name: d['name'] ?? '',
      locationText: d['locationText'] ?? '',
      lat: (d['lat'] as num?)?.toDouble() ?? 0,
      lng: (d['lng'] as num?)?.toDouble() ?? 0,
      radiusKm: (d['radiusKm'] as num?)?.toDouble() ?? 5,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'seekerId': seekerId,
        'name': name,
        'locationText': locationText,
        'lat': lat,
        'lng': lng,
        'radiusKm': radiusKm,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
