import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/ontherack_constants.dart';
import '../../../providers/catalog_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/stars.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  const WriteReviewScreen({super.key, required this.equipmentId});

  final String equipmentId;

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  final _comment = TextEditingController();
  int _condition = 4;
  String _availability = kAvailabilityOptions.first.value;
  DateTime? _lastSeen;
  bool _saving = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastSeen ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
    );
    if (picked != null) setState(() => _lastSeen = picked);
  }

  Future<void> _save() async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(catalogServiceProvider).addReview(
            session: session,
            equipmentId: widget.equipmentId,
            condition: _condition,
            availability: _availability,
            comment: _comment.text,
            lastSeenWorking: _lastSeen,
          );
      bumpCatalog(ref);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save review: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = ref.watch(equipmentItemProvider(widget.equipmentId));
    return Scaffold(
      appBar: AppBar(title: const Text('Write a review')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            item?.name ?? 'Equipment',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Review the machine or setup at this gym — condition and wait — not the venue as a whole.',
          ),
          const SizedBox(height: 16),
          const Text('Condition (1–5)'),
          StarInput(
            value: _condition,
            onChanged: (v) => setState(() => _condition = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _availability,
            decoration: const InputDecoration(labelText: 'Availability / wait'),
            items: kAvailabilityOptions
                .map(
                  (a) => DropdownMenuItem(
                    value: a.value,
                    child: Text('${a.label} — ${a.hint}'),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _availability = v);
            },
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _comment,
            label: 'Comment (optional)',
            maxLines: 5,
            maxLength: OnTheRackConstants.maxComment,
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _lastSeen == null
                  ? 'Last seen working (optional)'
                  : 'Last seen working: ${_lastSeen!.toIso8601String().split('T').first}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_lastSeen != null)
                  IconButton(
                    onPressed: () => setState(() => _lastSeen = null),
                    icon: const Icon(Icons.clear),
                  ),
                IconButton(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Publish review',
            isLoading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
