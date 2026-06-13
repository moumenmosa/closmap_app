import 'package:cloud_firestore/cloud_firestore.dart';

class LookupRepository {
  LookupRepository(this._db);

  final FirebaseFirestore _db;

  static const allDocIds = [
    'genders',
    'maritalStatuses',
    'nationalities',
    'countries',
    'proficiencyLevels',
    'employmentTypes',
    'educationLevels',
    'educationFields',
    'jobTitles',
    'experienceLevels',
    'companySectors',
    'companySizes',
    'remoteOptions',
    'genderTypes',
    'languages',
    'searchSuggestions',
  ];

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('lookups');

  Stream<List<String>> watchLookup(String docId) {
    return _col.doc(docId).snapshots().map(_valuesFromDoc);
  }

  Future<List<String>> getLookup(String docId) async {
    final doc = await _col.doc(docId).get();
    return _valuesFromDoc(doc);
  }

  Stream<Map<String, List<String>>> watchAllLookups() {
    return _col.snapshots().map((snap) {
      final map = <String, List<String>>{};
      for (final doc in snap.docs) {
        map[doc.id] = _valuesFromDoc(doc);
      }
      return map;
    });
  }

  Future<void> setLookupValues(String docId, List<String> values) async {
    await _col.doc(docId).set({'values': values}, SetOptions(merge: true));
  }

  Future<void> addValue(String docId, String value) async {
    final current = await getLookup(docId);
    if (current.contains(value)) return;
    await setLookupValues(docId, [...current, value]);
  }

  Future<void> removeValue(String docId, String value) async {
    final current = await getLookup(docId);
    await setLookupValues(
      docId,
      current.where((v) => v != value).toList(),
    );
  }

  List<String> _valuesFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists) return [];
    final raw = doc.data()?['values'];
    if (raw is! List) return [];
    return raw.map((e) => e.toString()).toList();
  }
}
