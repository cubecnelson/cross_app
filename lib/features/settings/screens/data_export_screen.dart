import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/workout_provider.dart';
import '../../../providers/export_provider.dart';

class DataExportScreen extends ConsumerStatefulWidget {
  const DataExportScreen({super.key});

  @override
  ConsumerState<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends ConsumerState<DataExportScreen> {
  bool _exporting = false;
  bool _includeCSV = true;
  bool _includePDF = false;
  
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final exportStatsAsync = ref.watch(exportStatsProvider);
    final workoutsAsync = ref.watch(workoutsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.download_outlined, size: 48, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text(
                      'Export Your Workout Data',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Download your complete workout history in CSV or PDF format for backup, '
                      'analysis, or import into other applications.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Statistics
            Text(
              'Your Workout Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            
            exportStatsAsync.when(
              data: (stats) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _StatRow(
                        label: 'Total Workouts',
                        value: stats['totalWorkouts'].toString(),
                        icon: Icons.fitness_center,
                      ),
                      _StatRow(
                        label: 'Total Sets',
                        value: stats['totalSets'].toString(),
                        icon: Icons.format_list_numbered,
                      ),
                      if (stats['totalVolume'] != '0.0') ...[
                        _StatRow(
                          label: 'Total Volume',
                          value: '${stats['totalVolume']} kg',
                          icon: Icons.scale,
                        ),
                      ],
                      _StatRow(
                        label: 'Date Range',
                        value: stats['dateRange'],
                        icon: Icons.calendar_today,
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading statistics: $error'),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Export Options
            Text(
              'Export Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // CSV Option
                    SwitchListTile.adaptive(
                      title: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CSV Export',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Spreadsheet format compatible with Excel, Google Sheets, etc.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      value: _includeCSV,
                      onChanged: (value) {
                        setState(() {
                          _includeCSV = value;
                        });
                      },
                    ),
                    
                    // PDF Option
                    SwitchListTile.adaptive(
                      title: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PDF Export',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Printable document with workout summaries and statistics.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      value: _includePDF,
                      onChanged: (value) {
                        setState(() {
                          _includePDF = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Information
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your data will be exported and shared via your device\'s sharing system.',
                              style: TextStyle(
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Export Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: user != null && !_exporting
                    ? () => _handleExport(ref)
                    : null,
                icon: _exporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_outlined),
                label: Text(
                  _exporting ? 'Exporting...' : 'Export Data',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Warning for no data
            if (user != null)
              workoutsAsync.when(
                data: (workouts) {
                  if (workouts.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_outlined, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You don\'t have any workouts yet. Start tracking your workouts to export data.',
                              style: TextStyle(
                                color: Colors.orange[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => const SizedBox.shrink(),
              ),
            
            const SizedBox(height: 24),
            
            // Export Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How To Use Exported Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InstructionStep(
                      number: 1,
                      text: 'After export, use your device\'s sharing options to save to files, email, or cloud storage.',
                    ),
                    _InstructionStep(
                      number: 2,
                      text: 'CSV files can be opened in Excel, Google Sheets, Numbers, or any spreadsheet software.',
                    ),
                    _InstructionStep(
                      number: 3,
                      text: 'Use your data for analysis, creating charts, or tracking progress over time.',
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
  
  Future<void> _handleExport(WidgetRef ref) async {
    if (!_includeCSV && !_includePDF) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one export format'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() => _exporting = true);
    
    try {
      final workoutsAsync = ref.read(workoutsProvider);
      final exportService = ref.read(exportServiceProvider);
      
      workoutsAsync.when(
        data: (workouts) async {
          if (workouts.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No workouts to export'),
                backgroundColor: Colors.orange,
              ),
            );
            setState(() => _exporting = false);
            return;
          }
          
          try {
            // Export based on selected formats
            if (_includeCSV) {
              await exportService.exportWorkoutsToCSV(workouts);
            }
            if (_includePDF) {
              await exportService.exportWorkoutsToPDF(workouts);
            }
            
            // Show success
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Successfully exported ${workouts.length} workouts!',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Export failed: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        loading: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loading workout data...'),
            ),
          );
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load workouts: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  
  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int number;
  final String text;
  
  const _InstructionStep({
    required this.number,
    required this.text,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}