import 'package:cloud_firestore/cloud_firestore.dart';

class EmployerProfile {
  final String uid;
  final String companyName;
  final String about;
  final String sector;
  final String activity;
  final String nationality;
  final String size;
  final DateTime? established;
  final String logoUrl;
  final String coverUrl;
  final String registrationNumber;
  final String certificateUrl;
  final String hqAddress;
  final String city;
  final String country;
  final String nearbyLandmarks;
  final String operatingHours;
  final String servicesOffered;
  final String website;
  final double? lat;
  final double? lng;
  final String geohash;
  final DateTime? updatedAt;

  const EmployerProfile({
    required this.uid,
    this.companyName = '',
    this.about = '',
    this.sector = '',
    this.activity = '',
    this.nationality = '',
    this.size = '',
    this.established,
    this.logoUrl = '',
    this.coverUrl = '',
    this.registrationNumber = '',
    this.certificateUrl = '',
    this.hqAddress = '',
    this.city = '',
    this.country = '',
    this.nearbyLandmarks = '',
    this.operatingHours = '',
    this.servicesOffered = '',
    this.website = '',
    this.lat,
    this.lng,
    this.geohash = '',
    this.updatedAt,
  });

  bool get hasLocation => lat != null && lng != null;

  factory EmployerProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return EmployerProfile(
      uid: doc.id,
      companyName: d['companyName'] ?? '',
      about: d['about'] ?? '',
      sector: d['sector'] ?? '',
      activity: d['activity'] ?? '',
      nationality: d['nationality'] ?? '',
      size: d['size'] ?? '',
      established: (d['established'] as Timestamp?)?.toDate(),
      logoUrl: d['logoUrl'] ?? '',
      coverUrl: d['coverUrl'] ?? '',
      registrationNumber: d['registrationNumber'] ?? '',
      certificateUrl: d['certificateUrl'] ?? '',
      hqAddress: d['hqAddress'] ?? '',
      city: d['city'] ?? '',
      country: d['country'] ?? '',
      nearbyLandmarks: d['nearbyLandmarks'] ?? '',
      operatingHours: d['operatingHours'] ?? '',
      servicesOffered: d['servicesOffered'] ?? '',
      website: d['website'] ?? '',
      lat: (d['lat'] as num?)?.toDouble(),
      lng: (d['lng'] as num?)?.toDouble(),
      geohash: d['geohash'] ?? '',
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'companyName': companyName,
        'about': about,
        'sector': sector,
        'activity': activity,
        'nationality': nationality,
        'size': size,
        'established':
            established != null ? Timestamp.fromDate(established!) : null,
        'logoUrl': logoUrl,
        'coverUrl': coverUrl,
        'registrationNumber': registrationNumber,
        'certificateUrl': certificateUrl,
        'hqAddress': hqAddress,
        'city': city,
        'country': country,
        'nearbyLandmarks': nearbyLandmarks,
        'operatingHours': operatingHours,
        'servicesOffered': servicesOffered,
        'website': website,
        'lat': lat,
        'lng': lng,
        'geohash': geohash,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
