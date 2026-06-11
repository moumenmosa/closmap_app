import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/services.dart';



class SeedService {

  SeedService(this._db);



  final FirebaseFirestore _db;



  /// Seeds catalog collections only. Requires admin rules or will fail — use

  /// `npm run seed` in tools/ for the full demo dataset.

  Future<void> seedLookups() async {

    final raw = await rootBundle.loadString('seed/seed_data.json');

    final data = jsonDecode(raw) as Map<String, dynamic>;



    final batch = _db.batch();



    final plans = data['plans'] as Map<String, dynamic>? ?? {};

    for (final e in plans.entries) {

      batch.set(_db.collection('plans').doc(e.key), e.value as Map<String, dynamic>);

    }



    final packages = data['pointPackages'] as Map<String, dynamic>? ?? {};

    for (final e in packages.entries) {

      batch.set(

        _db.collection('pointPackages').doc(e.key),

        e.value as Map<String, dynamic>,

      );

    }



    final lookups = data['lookups'] as Map<String, dynamic>? ?? {};

    for (final e in lookups.entries) {

      batch.set(_db.collection('lookups').doc(e.key), {'values': e.value});

    }

    final leaderboard = data['leaderboard'] as List<dynamic>? ?? [];

    for (final entry in leaderboard) {

      final map = entry as Map<String, dynamic>;

      final id = map['id']?.toString() ?? map['rank']?.toString();

      if (id == null) continue;

      final doc = Map<String, dynamic>.from(map)..remove('id');

      batch.set(_db.collection('leaderboard').doc(id), doc);

    }

    await batch.commit();

  }

}

