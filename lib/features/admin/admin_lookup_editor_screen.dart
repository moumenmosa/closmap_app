import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/lookup_providers.dart';
import '../../core/widgets/common_widgets.dart';

class AdminLookupEditorScreen extends ConsumerStatefulWidget {
  const AdminLookupEditorScreen({super.key, required this.docId});

  final String docId;

  @override
  ConsumerState<AdminLookupEditorScreen> createState() =>
      _AdminLookupEditorScreenState();
}

class _AdminLookupEditorScreenState
    extends ConsumerState<AdminLookupEditorScreen> {
  final _addController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _addValue(List<String> current) async {
    final value = _addController.text.trim();
    if (value.isEmpty) return;
    if (current.contains(value)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Value already exists')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(lookupRepositoryProvider)
          .setLookupValues(widget.docId, [...current, value]);
      _addController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _removeValue(List<String> current, String value) async {
    setState(() => _saving = true);
    try {
      await ref.read(lookupRepositoryProvider).setLookupValues(
            widget.docId,
            current.where((v) => v != value).toList(),
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final valuesAsync = ref.watch(lookupValuesProvider(widget.docId));

    return Scaffold(
      appBar: AppBar(title: Text(widget.docId)),
      body: valuesAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(message: '$e'),
        data: (values) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _addController,
                        decoration: const InputDecoration(
                          labelText: 'New value',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !_saving,
                        onSubmitted: (_) => _addValue(values),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed:
                          _saving ? null : () => _addValue(values),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              if (values.isEmpty)
                Expanded(
                  child: EmptyState(
                    message: 'No values in Firestore. Add one above or seed catalog.',
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(lookupValuesProvider(widget.docId));
                    },
                    child: ListView.builder(
                      itemCount: values.length,
                      itemBuilder: (_, i) {
                        final v = values[i];
                        return ListTile(
                          title: Text(v),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: _saving
                                ? null
                                : () => _removeValue(values, v),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
