import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/ontherack_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../data/hk_districts.dart';
import '../../../providers/catalog_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import 'gym_detail_screen.dart';

class AddGymScreen extends ConsumerStatefulWidget {
  const AddGymScreen({super.key});

  @override
  ConsumerState<AddGymScreen> createState() => _AddGymScreenState();
}

class _AddGymScreenState extends ConsumerState<AddGymScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _chain = TextEditingController();
  final _hours = TextEditingController();
  final _website = TextEditingController();
  final _maps = TextEditingController();
  String? _district;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _chain.dispose();
    _hours.dispose();
    _website.dispose();
    _maps.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final session = ref.read(sessionProvider);
    if (session == null) return;
    setState(() => _saving = true);
    try {
      final gym = await ref.read(catalogServiceProvider).addGym(
            session: session,
            name: _name.text,
            district: _district!,
            address: _address.text,
            chain: _chain.text,
            hours: _hours.text,
            website: _website.text,
            mapsUrl: _maps.text,
          );
      bumpCatalog(ref);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => GymDetailScreen(gymId: gym.id)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add gym: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final choices = allHongKongDistrictChoices();
    return Scaffold(
      appBar: AppBar(title: const Text('Add a gym')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'List a gym so others can review the equipment on its floor. Do not present official data as verified.',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _name,
              label: 'Gym name',
              maxLength: OnTheRackConstants.maxName,
              validator: (v) => Validators.validateRequired(v, 'Gym name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _district,
              decoration: const InputDecoration(labelText: 'District'),
              items: choices
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => _district = v),
              validator: (v) =>
                  v == null || v.isEmpty ? 'District is required' : null,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _address,
              label: 'Address',
              maxLines: 2,
              maxLength: OnTheRackConstants.maxAddress,
              validator: (v) => Validators.validateRequired(v, 'Address'),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _chain,
              label: 'Chain or operator (optional)',
              maxLength: OnTheRackConstants.maxName,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _hours,
              label: 'Hours (optional)',
              hint: 'Confirm on site if you are unsure',
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _website,
              label: 'Website (optional)',
              keyboardType: TextInputType.url,
              maxLength: OnTheRackConstants.maxUrl,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _maps,
              label: 'Maps URL (optional)',
              keyboardType: TextInputType.url,
              maxLength: OnTheRackConstants.maxUrl,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Add gym',
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
