import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/lookup_providers.dart';
import '../../core/repositories/lookup_repository.dart';
import '../../core/widgets/common_widgets.dart';

class AdminLookupsScreen extends ConsumerWidget {
  const AdminLookupsScreen({super.key});

  static const _labels = <String, String>{
    'genders': 'Genders',
    'maritalStatuses': 'Marital statuses',
    'nationalities': 'Nationalities',
    'countries': 'Countries',
    'proficiencyLevels': 'Proficiency levels',
    'employmentTypes': 'Employment types',
    'educationLevels': 'Education levels',
    'educationFields': 'Education fields',
    'jobTitles': 'Job titles',
    'experienceLevels': 'Experience levels',
    'companySectors': 'Company sectors',
    'companySizes': 'Company sizes',
    'remoteOptions': 'Remote options',
    'genderTypes': 'Gender types (jobs)',
    'languages': 'Languages',
    'searchSuggestions': 'Search suggestions',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lookupsAsync = ref.watch(allLookupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage lookups')),
      body: lookupsAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(message: '$e'),
        data: (lookups) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allLookupsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: LookupRepository.allDocIds.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final docId = LookupRepository.allDocIds[i];
                final values = lookups[docId] ?? [];
                final count = values.isNotEmpty
                    ? values.length
                    : lookupFallback(docId).length;
                return Card(
                  child: ListTile(
                    title: Text(_labels[docId] ?? docId),
                    subtitle: Text(
                      values.isEmpty
                          ? '$count values (fallback)'
                          : '$count values',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/admin/lookups/$docId'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
