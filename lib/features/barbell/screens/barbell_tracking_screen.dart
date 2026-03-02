import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../services/vbt_barbell_service.dart';

/// Screen for live barbell tracking during workouts
class BarbellTrackingScreen extends StatefulWidget {
  final double? barbellRadiusMm;
  final Function(BarbellMetrics)? onMetricsUpdate;
  final Function()? onTrackingComplete;

  const BarbellTrackingScreen({
    super.key,
    this.barbellRadiusMm,
    this.onMetricsUpdate,
    this.onTrackingComplete,
  });

  @override
  State<BarbellTrackingScreen> createState() => _BarbellTrackingScreenState();
}

class _BarbellTrackingScreenState extends State<BarbellTrackingScreen> {
  late CameraController _cameraController;
  late VbtBarbellService _vbtService;
  StreamSubscription<BarbellMetrics>? _metricsSubscription;
  bool _isInitialized = false;
  bool _isTracking = false;
  String _status = 'Initializing camera...';
  BarbellMetrics? _currentMetrics;
  List<BarbellMetrics> _metricsHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _metricsSubscription?.cancel();
    _vbtService.stopTracking();
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameraController = await VbtCameraService.initializeCamera();
      await _cameraController.initialize();
      _vbtService = VbtBarbellService(_cameraController);
      
      setState(() {
        _isInitialized = true;
        _status = 'Ready to track';
      });
    } catch (e) {
      setState(() {
        _status = 'Camera initialization failed: $e';
      });
    }
  }

  void _startTracking() {
    if (!_isInitialized) return;
    
    setState(() {
      _isTracking = true;
      _status = 'Tracking barbell...';
    });
    
    final metricsStream = _vbtService.startTracking(
      barbellRadiusMm: widget.barbellRadiusMm ?? 25.0,
    );
    
    _metricsSubscription = metricsStream.listen((metrics) {
      setState(() {
        _currentMetrics = metrics;
        _metricsHistory.add(metrics);
        
        if (metrics.shouldEndSet) {
          _status = '⚠️ Velocity loss detected - consider ending set';
        }
      });
      
      // Notify parent
      widget.onMetricsUpdate?.call(metrics);
    });
  }

  void _stopTracking() {
    setState(() {
      _isTracking = false;
      _status = 'Tracking stopped';
    });
    
    _metricsSubscription?.cancel();
    _vbtService.stopTracking();
  }

  void _resetTracking() {
    _vbtService.reset();
    setState(() {
      _currentMetrics = null;
      _metricsHistory.clear();
      _status = 'Ready to track';
    });
  }

  void _completeTracking() {
    _stopTracking();
    widget.onTrackingComplete?.call();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barbell Velocity Tracking'),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetTracking,
            tooltip: 'Reset tracking',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _completeTracking,
            tooltip: 'Complete and save',
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Camera preview
          Expanded(
            flex: 3,
            child: _buildCameraPreview(),
          ),
          
          // Metrics display
          Expanded(
            flex: 2,
            child: _buildMetricsPanel(),
          ),
        ],
      ),
      floatingActionButton: _buildTrackingButton(),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_status),
          ],
        ),
      );
    }
    
    return Stack(
      children: [
        CameraPreview(_cameraController),
        
        // Tracking overlay
        if (_isTracking)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'LIVE TRACKING',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Instructions overlay
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Instructions:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '1. Place a green marker on barbell end\n'
                  '2. Position barbell in camera view\n'
                  '3. Start tracking and perform your set',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_currentMetrics != null)
                  Text(
                    'Rep ${_currentMetrics!.repCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Metrics grid
          Expanded(
            child: _currentMetrics != null
                ? _buildMetricsGrid()
                : _buildPlaceholderMetrics(),
          ),
          
          // History summary
          if (_metricsHistory.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHistoryMetric(
                    'Best Vel',
                    '${_getBestVelocity().toStringAsFixed(2)} m/s',
                  ),
                  _buildHistoryMetric(
                    'Avg Loss',
                    '${_getAverageVelocityLoss().toStringAsFixed(1)}%',
                  ),
                  _buildHistoryMetric(
                    'Total Reps',
                    '${_metricsHistory.last.repCount}',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = _currentMetrics!;
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _buildMetricCard(
          'Average Velocity',
          '${metrics.averageVelocity.toStringAsFixed(2)} m/s',
          _getVelocityColor(metrics.averageVelocity),
        ),
        _buildMetricCard(
          'Peak Velocity',
          '${metrics.peakVelocity.toStringAsFixed(2)} m/s',
          _getVelocityColor(metrics.peakVelocity),
        ),
        _buildMetricCard(
          'Displacement',
          '${metrics.displacement.toStringAsFixed(0)} mm',
          Colors.blue,
        ),
        _buildMetricCard(
          'Velocity Loss',
          '${metrics.velocityLoss.toStringAsFixed(1)}%',
          metrics.velocityLoss > 20 ? Colors.red : Colors.green,
        ),
      ],
    );
  }

  Widget _buildPlaceholderMetrics() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Start tracking to see metrics',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryMetric(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingButton() {
    return FloatingActionButton.extended(
      onPressed: _isInitialized
          ? () => _isTracking ? _stopTracking() : _startTracking()
          : null,
      icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
      label: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
      backgroundColor: _isTracking ? Colors.red : Colors.green,
      foregroundColor: Colors.white,
    );
  }

  // Helper methods
  Color _getStatusColor() {
    if (_currentMetrics?.shouldEndSet == true) {
      return Colors.red;
    } else if (_isTracking) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  Color _getVelocityColor(double velocity) {
    if (velocity > 1.0) return Colors.green;
    if (velocity > 0.5) return Colors.yellow;
    return Colors.red;
  }

  double _getBestVelocity() {
    if (_metricsHistory.isEmpty) return 0.0;
    double best = 0.0;
    for (final metrics in _metricsHistory) {
      if (metrics.peakVelocity > best) {
        best = metrics.peakVelocity;
      }
    }
    return best;
  }

  double _getAverageVelocityLoss() {
    if (_metricsHistory.length < 2) return 0.0;
    double totalLoss = 0.0;
    int count = 0;
    for (int i = 1; i < _metricsHistory.length; i++) {
      totalLoss += _metricsHistory[i].velocityLoss;
      count++;
    }
    return count > 0 ? totalLoss / count : 0.0;
  }
}