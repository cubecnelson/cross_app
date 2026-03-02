import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/barbell_service.dart';

class OneRepMaxScreen extends ConsumerStatefulWidget {
  const OneRepMaxScreen({super.key});

  @override
  ConsumerState<OneRepMaxScreen> createState() => _OneRepMaxScreenState();
}

class _OneRepMaxScreenState extends ConsumerState<OneRepMaxScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController(text: '5');
  
  bool _useKg = true;
  Map<String, double> _oneRepMaxResults = {};
  List<Map<String, dynamic>> _percentageTable = [];

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_calculateOneRepMax);
    _repsController.addListener(_calculateOneRepMax);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _calculateOneRepMax() {
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final reps = int.tryParse(_repsController.text) ?? 1;

    if (weight <= 0 || reps < 1) {
      setState(() {
        _oneRepMaxResults = {};
        _percentageTable = [];
      });
      return;
    }

    final results = BarbellService.calculateOneRepMax(
      weight: weight,
      reps: reps,
    );

    setState(() {
      _oneRepMaxResults = results;
      _generatePercentageTable(results['average'] ?? weight);
    });
  }

  void _generatePercentageTable(double estimated1RM) {
    final percentages = [0.5, 0.6, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1.0];
    final plateIncrement = _useKg ? 2.5 : 5.0;

    _percentageTable = percentages.map((percentage) {
      final rawWeight = estimated1RM * percentage;
      final roundedWeight = rawWeight.roundToNearest(plateIncrement);
      
      return {
        'percentage': (percentage * 100).toInt(),
        'weight': roundedWeight,
        'plates': BarbellService.calculatePlates(
          targetWeight: roundedWeight,
          barWeight: _useKg ? 20.0 : 45.0,
          availablePlates: _useKg ? BarbellService.kgPlates : BarbellService.lbPlates,
          includeBarWeight: true,
        ),
      };
    }).toList();
  }

  void _toggleUnit() {
    setState(() {
      _useKg = !_useKg;
      
      // Convert current weight if needed
      if (_weightController.text.isNotEmpty) {
        final currentWeight = double.tryParse(_weightController.text) ?? 0.0;
        final convertedWeight = _useKg 
            ? BarbellService.lbToKg(currentWeight)
            : BarbellService.kgToLb(currentWeight);
        _weightController.text = convertedWeight.toStringAsFixed(1);
      }
      
      _calculateOneRepMax();
    });
  }

  void _setReps(int reps) {
    setState(() {
      _repsController.text = reps.toString();
      _calculateOneRepMax();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1RM Calculator'),
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
            // Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calculate Your 1RM',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    
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
                        Expanded(
                          child: TextField(
                            controller: _repsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.repeat),
                              labelText: 'Reps',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Quick Reps:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [1, 3, 5, 8, 10].map((reps) {
                        return FilterChip(
                          label: Text('$reps reps'),
                          selected: _repsController.text == reps.toString(),
                          onSelected: (_) => _setReps(reps),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Results Section
            if (_oneRepMaxResults.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimated 1RM',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      
                      // Average 1RM (primary result)
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Average',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Most accurate estimate',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Text(
                              '${_oneRepMaxResults['average']!.toStringAsFixed(1)} ${_useKg ? 'kg' : 'lb'}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Other formulas
                      Text(
                        'Different Formulas:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _oneRepMaxResults.entries
                            .where((entry) => entry.key != 'average')
                            .map((entry) {
                          final formula = entry.key;
                          final value = entry.value;
                          
                          return Chip(
                            label: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  formula[0].toUpperCase() + formula.substring(1),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  '${value.toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: _getFormulaColor(formula),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Percentage Table
            if (_percentageTable.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Training Percentages',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Weights rounded to nearest ${_useKg ? '2.5kg' : '5lb'} plate',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1.5),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(3),
                        },
                        border: TableBorder.all(
                          color: Colors.grey[300]!,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  '%',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  'Weight',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  'Plates (per side)',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          ..._percentageTable.map((row) {
                            final percentage = row['percentage'] as int;
                            final weight = row['weight'] as double;
                            final plates = row['plates'] as List<double>;
                            
                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    '$percentage%',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _getPercentageColor(percentage),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    '${weight.toStringAsFixed(1)} ${_useKg ? 'kg' : 'lb'}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Wrap(
                                    spacing: 4,
                                    children: plates.map((plate) {
                                      return Chip(
                                        label: Text('${plate.toStringAsFixed(1)}'),
                                        backgroundColor: _getPlateColor(plate, _useKg),
                                        labelStyle: const TextStyle(fontSize: 10),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Training Zones Explanation
                      ExpansionTile(
                        title: Text(
                          'Training Zones',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildZoneRow('50-60%', 'Warm-up/Light technique work'),
                                _buildZoneRow('65-75%', 'Hypertrophy/Strength endurance'),
                                _buildZoneRow('80-85%', 'Strength development'),
                                _buildZoneRow('90-95%', 'Peak strength/Competition prep'),
                                _buildZoneRow('100%', '1RM/Max effort'),
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

            // Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to Use',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the weight you lifted and how many reps you completed. '
                      'The calculator will estimate your one-rep maximum using multiple formulas.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tips:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTip('• Use 3-5 reps for most accurate results'),
                          _buildTip('• Test with 85-90% of your estimated 1RM'),
                          _buildTip('• The "Average" formula gives the best estimate'),
                          _buildTip('• Always use a spotter when testing 1RM'),
                        ],
                      ),
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

  Widget _buildZoneRow(String percentage, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            child: Text(
              percentage,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(description),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Color _getFormulaColor(String formula) {
    final colors = {
      'epley': Colors.blue[100]!,
      'brzycki': Colors.green[100]!,
      'lombardi': Colors.yellow[100]!,
      'oconner': Colors.orange[100]!,
      'wathan': Colors.purple[100]!,
    };
    return colors[formula] ?? Colors.grey[100]!;
  }

  Color _getPercentageColor(int percentage) {
    if (percentage >= 90) return Colors.red;
    if (percentage >= 80) return Colors.orange;
    if (percentage >= 70) return Colors.yellow[700]!;
    if (percentage >= 60) return Colors.green;
    return Colors.blue;
  }

  Color _getPlateColor(double plate, bool isKg) {
    if (isKg) {
      if (plate >= 25) return Colors.red;
      if (plate >= 20) return Colors.blue;
      if (plate >= 15) return Colors.yellow;
      if (plate >= 10) return Colors.green;
      if (plate >= 5) return Colors.white;
      return Colors.grey;
    } else {
      if (plate >= 45) return Colors.blue;
      if (plate >= 35) return Colors.yellow;
      if (plate >= 25) return Colors.green;
      if (plate >= 10) return Colors.white;
      if (plate >= 5) return Colors.red;
      return Colors.grey;
    }
  }
}