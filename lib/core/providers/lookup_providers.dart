import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/lookups.dart';
import '../repositories/lookup_repository.dart';
import 'providers.dart';

final lookupRepositoryProvider = Provider<LookupRepository>((ref) {
  return LookupRepository(ref.watch(firestoreProvider));
});

/// Resolves static fallback for a lookup doc id.
List<String> lookupFallback(String docId) {
  switch (docId) {
    case 'genders':
      return Lookups.genders;
    case 'maritalStatuses':
      return Lookups.maritalStatuses;
    case 'nationalities':
      return Lookups.nationalities;
    case 'countries':
      return Lookups.countries;
    case 'proficiencyLevels':
      return Lookups.proficiencyLevels;
    case 'employmentTypes':
      return Lookups.employmentTypes;
    case 'educationLevels':
      return Lookups.educationLevels;
    case 'educationFields':
      return Lookups.educationFields;
    case 'jobTitles':
      return Lookups.jobTitles;
    case 'experienceLevels':
      return Lookups.experienceLevels;
    case 'companySectors':
      return Lookups.companySectors;
    case 'companySizes':
      return Lookups.companySizes;
    case 'remoteOptions':
      return Lookups.remoteOptions;
    case 'genderTypes':
      return Lookups.genderTypes;
    case 'languages':
      return Lookups.languages;
    case 'searchSuggestions':
      return Lookups.searchSuggestions;
    default:
      return const [];
  }
}

final lookupValuesProvider =
    StreamProvider.family<List<String>, String>((ref, docId) {
  final fallback = lookupFallback(docId);
  return ref.watch(lookupRepositoryProvider).watchLookup(docId).map((values) {
    if (values.isEmpty) return fallback;
    return values;
  });
});

final allLookupsProvider = StreamProvider<Map<String, List<String>>>((ref) {
  return ref.watch(lookupRepositoryProvider).watchAllLookups();
});

/// Convenience for widgets: returns live values or static fallback.
List<String> lookupList(WidgetRef ref, String docId) {
  return ref.watch(lookupValuesProvider(docId)).valueOrNull ??
      lookupFallback(docId);
}

/// Integer options (validity days) — not stored in Firestore seed.
List<String> lookupIntOptions(WidgetRef ref, String docId, List<int> fallback) {
  if (docId == 'validityDaysOptions') {
    final live = ref.watch(lookupValuesProvider(docId)).valueOrNull;
    if (live != null && live.isNotEmpty) {
      return live;
    }
    return fallback.map((e) => e.toString()).toList();
  }
  return lookupList(ref, docId);
}
