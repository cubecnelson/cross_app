import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/ontherack_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/catalog_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import 'equipment_detail_screen.dart';

class AddEquipmentScreen extends ConsumerStatefulWidget {
  const AddEquipmentScreen({super.key, required this.gymId});

  final String gymId;

  @override
  ConsumerState<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends ConsumerState<AddEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _notes = TextEditingController();
  final _imageUrl = TextEditingController();
  String _category = kEquipmentCategories.first.value;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final session = ref.read(sessionProvider);
    if (session == null) return;
    setState(() => _saving = true);
    try {
      final item = await ref.read(catalogServiceProvider).addEquipment(
            session: session,
            gymId: widget.gymId,
            name: _name.text,
            category: _category,
            notes: _notes.text,
            imageUrl: _imageUrl.text,
          );
      bumpCatalog(ref);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EquipmentDetailScreen(equipmentId: item.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add equipment: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add equipment')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Add a machine, rack, cardio unit, or free-weight setup you have seen at this gym.',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _name,
              label: 'Equipment name',
              hint: 'e.g. Squat rack, Treadmill bank',
              maxLength: OnTheRackConstants.maxName,
              validator: (v) => Validators.validateRequired(v, 'Equipment name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: kEquipmentCategories
                  .map((c) => DropdownMenuItem(value: c.value, child: Text(c.label)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _notes,
              label: 'Notes (optional)',
              hint: 'How many units, where they sit, quirks…',
              maxLines: 3,
              maxLength: OnTheRackConstants.maxNotes,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _imageUrl,
              label: 'Photo URL (optional)',
              keyboardType: TextInputType.url,
              maxLength: OnTheRackConstants.maxUrl,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Add equipment',
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
