import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/barbell_service.dart';

class PlateCalculatorScreen extends ConsumerStatefulWidget {
  final double? initialWeight;
  
  const PlateCalculatorScreen({super.key, this.initialWeight});

  @override
  ConsumerState<PlateCalculatorScreen> createState() => _PlateCalculatorScreenState();
}

class _PlateCalculatorScreenState extends ConsumerState<PlateCalculatorScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _barWeightController = TextEditingController(text: '20.0');
  
  bool _useKg = true;
  List<double> _availablePlates = BarbellService.kgPlates;
  List<double> _platesPerSide = [];
  double _totalWeight = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.initialWeight != null && widget.initialWeight! > 0) {
      _weightController.text = widget.initialWeight!.toStringAsFixed(1);
    }
    _weightController.addListener(_calculatePlates);
    _barWeightController.addListener(_calculatePlates);
    // Calculate plates initially if we have an initial weight
    if (widget.initialWeight != null && widget.initialWeight! > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculatePlates();
      });
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _barWeightController.dispose();
    super.dispose();
  }

  void _calculatePlates() {
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final barWeight = double.tryParse(_barWeightController.text) ?? 20.0;

    if (weight <= 0) {
      setState(() {
        _platesPerSide = [];
        _totalWeight = 0.0;
      });
      return;
    }

    final plates = BarbellService.calculatePlates(
      targetWeight: weight,
      barWeight: barWeight,
      availablePlates: _availablePlates,
      includeBarWeight: true,
    );

    setState(() {
      _platesPerSide = plates;
      _totalWeight = BarbellService.calculateTotalWeight(
        platesPerSide: plates,
        barWeight: barWeight,
      );
    });
  }

  void _toggleUnit() {
    setState(() {
      _useKg = !_useKg;
      _availablePlates = _useKg ? BarbellService.kgPlates : BarbellService.lbPlates;
      
      // Convert current weight if needed
      if (_weightController.text.isNotEmpty) {
        final currentWeight = double.tryParse(_weightController.text) ?? 0.0;
        final convertedWeight = _useKg 
            ? BarbellService.lbToKg(currentWeight)
            : BarbellService.kgToLb(currentWeight);
        _weightController.text = convertedWeight.toStringAsFixed(1);
      }
      
      // Convert bar weight
      final barWeight = double.tryParse(_barWeightController.text) ?? 20.0;
      final convertedBarWeight = _useKg 
          ? BarbellService.lbToKg(barWeight)
          : BarbellService.kgToLb(barWeight);
      _barWeightController.text = convertedBarWeight.toStringAsFixed(1);
      
      _calculatePlates();
    });
  }

  void _addQuickWeight(double weight) {
    final currentWeight = double.tryParse(_weightController.text) ?? 0.0;
    final newWeight = currentWeight + weight;
    _weightController.text = newWeight.toStringAsFixed(1);
    _calculatePlates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plate Calculator'),
        actions: [
          IconButton(
            icon: Icon(_useKg ? Icons.language : Icons.language_outlined),
            onPressed: _toggleUnit,
            tooltip: _useKg ? 'Switch to lbs' : 'Switch to kg',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Weight Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Weight',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.fitness_center),
                              labelText: 'Weight (${_useKg ? 'kg' : 'lb'})',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).colorScheme.primary),
                          ),
                          child: Text(
                            '${_useKg ? 'kg' : 'lb'}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bar Weight',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _barWeightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.straighten),
                        labelText: 'Bar weight (${_useKg ? 'kg' : 'lb'})',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Add Buttons
            Text(
              'Quick Add',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final weight in _useKg 
                    ? [2.5, 5.0, 10.0, 20.0, 25.0]
                    : [5.0, 10.0, 25.0, 45.0]
                )
                  FilterChip(
                    label: Text('+$weight'),
                    onSelected: (_) => _addQuickWeight(weight),
                  ),
              ],
            ),

            const SizedBox(height: 32),

            // Results Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plates Per Side',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    if (_platesPerSide.isEmpty && _weightController.text.isNotEmpty)
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cannot make exact weight with available plates',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else if (_platesPerSide.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.fitness_center_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Enter a target weight to calculate plates',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          // Barbell Visualization
                          _buildBarbellVisualization(),
                          const SizedBox(height: 24),
                          
                          // Plates List
                          Text(
                            'Plates (each side):',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _platesPerSide
                                .asMap()
                                .entries
                                .map((entry) {
                              final index = entry.key;
                              final plate = entry.value;
                              return Chip(
                                label: Text('${plate.toStringAsFixed(1)} ${_useKg ? 'kg' : 'lb'}'),
                                backgroundColor: _getPlateColor(plate, _useKg),
                                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                              );
                            })
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          
                          // Total Weight
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Weight:',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '${_totalWeight.toStringAsFixed(1)} ${_useKg ? 'kg' : 'lb'}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Available Plates Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Plates',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Standard ${_useKg ? 'kg' : 'lb'} plates:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availablePlates.map((plate) {
                        return Chip(
                          label: Text('${plate.toStringAsFixed(1)} ${_useKg ? 'kg' : 'lb'}'),
                          backgroundColor: _getPlateColor(plate, _useKg),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarbellVisualization() {
    return Column(
      children: [
        // Top row of plates (right side)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left side collar
            Container(
              width: 20,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(4),
                ),
              ),
            ),
            
            // Plates
            ..._platesPerSide.map((plate) {
              return Container(
                width: 20 + plate.toInt() * 2, // Width based on plate size
                height: 60,
                decoration: BoxDecoration(
                  color: _getPlateColor(plate, _useKg),
                  border: Border.all(color: Colors.black, width: 1),
                ),
              );
            }),
            
            // Middle (bar)
            Container(
              width: 100,
              height: 60,
              color: Colors.grey[900],
              child: const Center(
                child: Text(
                  'BAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            
            // Plates (right side - reversed)
            ...List.generate(_platesPerSide.length, (index) {
              final plate = _platesPerSide[_platesPerSide.length - 1 - index];
              return Container(
                width: 20 + plate.toInt() * 2,
                height: 60,
                decoration: BoxDecoration(
                  color: _getPlateColor(plate, _useKg),
                  border: Border.all(color: Colors.black, width: 1),
                ),
              );
            }),
            
            // Right side collar
            Container(
              width: 20,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(4),
                ),
              ),
            ),
          ],
        ),
        
        // Bar line
        Container(
          height: 10,
          width: double.infinity,
          color: Colors.grey[800],
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        
        // Bottom row (mirrored)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left side collar
            Container(
              width: 20,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(4),
                ),
              ),
            ),
            
            // Plates (bottom - mirrored)
            ...List.generate(_platesPerSide.length, (index) {
              final plate = _platesPerSide[index];
              return Container(
                width: 20 + plate.toInt() * 2,
                height: 60,
                decoration: BoxDecoration(
                  color: _getPlateColor(plate, _useKg),
                  border: Border.all(color: Colors.black, width: 1),
                ),
              );
            }),
            
            // Middle (bar)
            Container(
              width: 100,
              height: 60,
              color: Colors.grey[900],
              child: const Center(
                child: Text(
                  'BAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            
            // Plates (right side - reversed)
            ...List.generate(_platesPerSide.length, (index) {
              final plate = _platesPerSide[_platesPerSide.length - 1 - index];
              return Container(
                width: 20 + plate.toInt() * 2,
                height: 60,
                decoration: BoxDecoration(
                  color: _getPlateColor(plate, _useKg),
                  border: Border.all(color: Colors.black, width: 1),
                ),
              );
            }),
            
            // Right side collar
            Container(
              width: 20,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getPlateColor(double plate, bool isKg) {
    // Color coding based on plate size (similar to real plates)
    if (isKg) {
      if (plate >= 25) return Colors.red;
      if (plate >= 20) return Colors.blue;
      if (plate >= 15) return Colors.yellow;
      if (plate >= 10) return Colors.green;
      if (plate >= 5) return Colors.white;
      return Colors.grey;
    } else {
      // lb plates
      if (plate >= 45) return Colors.blue;
      if (plate >= 35) return Colors.yellow;
      if (plate >= 25) return Colors.green;
      if (plate >= 10) return Colors.white;
      if (plate >= 5) return Colors.red;
      return Colors.grey;
    }
  }
}