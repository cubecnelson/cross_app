import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

final shorebirdCodePushProvider = Provider<ShorebirdCodePush>((ref) {
  throw UnimplementedError('shorebirdCodePushProvider should be overridden');
});

final shorebirdUpdateAvailableProvider = FutureProvider<bool>((ref) async {
  final shorebird = ref.watch(shorebirdCodePushProvider);
  
  try {
    // Check if a new patch is available
    final isUpdateAvailable = await shorebird.isNewPatchAvailableForDownload();
    return isUpdateAvailable;
  } catch (e) {
    // If there's an error, assume no update is available
    return false;
  }
});

final shorebirdCurrentPatchNumberProvider = FutureProvider<int?>((ref) async {
  final shorebird = ref.watch(shorebirdCodePushProvider);
  
  try {
    final currentPatchNumber = await shorebird.currentPatchNumber();
    return currentPatchNumber;
  } catch (e) {
    return null;
  }
});

final shorebirdNextPatchNumberProvider = FutureProvider<int?>((ref) async {
  final shorebird = ref.watch(shorebirdCodePushProvider);
  
  try {
    final nextPatchNumber = await shorebird.nextPatchNumber();
    return nextPatchNumber;
  } catch (e) {
    return null;
  }
});

class ShorebirdNotifier extends StateNotifier<ShorebirdState> {
  final ShorebirdCodePush _shorebird;
  
  ShorebirdNotifier(this._shorebird) : super(ShorebirdState.initial());

  Future<void> checkForUpdates() async {
    state = state.copyWith(checkingForUpdates: true);
    
    try {
      final isUpdateAvailable = await _shorebird.isNewPatchAvailableForDownload();
      final currentPatchNumber = await _shorebird.currentPatchNumber();
      final nextPatchNumber = await _shorebird.nextPatchNumber();
      
      state = state.copyWith(
        checkingForUpdates: false,
        updateAvailable: isUpdateAvailable,
        currentPatchNumber: currentPatchNumber,
        nextPatchNumber: nextPatchNumber,
        lastChecked: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        checkingForUpdates: false,
        error: e.toString(),
        lastChecked: DateTime.now(),
      );
    }
  }

  Future<bool> downloadUpdate() async {
    if (!state.updateAvailable) return false;
    
    state = state.copyWith(downloadingUpdate: true);
    
    try {
      await _shorebird.downloadUpdateIfAvailable();
      state = state.copyWith(
        downloadingUpdate: false,
        updateAvailable: false,
        updateDownloaded: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        downloadingUpdate: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> restartApp() async {
    // Note: Shorebird patches are applied automatically on next restart
    // This is just a placeholder for any restart logic you might want
    state = state.copyWith(restarting: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class ShorebirdState {
  final bool checkingForUpdates;
  final bool updateAvailable;
  final bool downloadingUpdate;
  final bool updateDownloaded;
  final bool restarting;
  final int? currentPatchNumber;
  final int? nextPatchNumber;
  final DateTime? lastChecked;
  final String? error;

  const ShorebirdState({
    required this.checkingForUpdates,
    required this.updateAvailable,
    required this.downloadingUpdate,
    required this.updateDownloaded,
    required this.restarting,
    this.currentPatchNumber,
    this.nextPatchNumber,
    this.lastChecked,
    this.error,
  });

  factory ShorebirdState.initial() {
    return const ShorebirdState(
      checkingForUpdates: false,
      updateAvailable: false,
      downloadingUpdate: false,
      updateDownloaded: false,
      restarting: false,
    );
  }

  ShorebirdState copyWith({
    bool? checkingForUpdates,
    bool? updateAvailable,
    bool? downloadingUpdate,
    bool? updateDownloaded,
    bool? restarting,
    int? currentPatchNumber,
    int? nextPatchNumber,
    DateTime? lastChecked,
    String? error,
  }) {
    return ShorebirdState(
      checkingForUpdates: checkingForUpdates ?? this.checkingForUpdates,
      updateAvailable: updateAvailable ?? this.updateAvailable,
      downloadingUpdate: downloadingUpdate ?? this.downloadingUpdate,
      updateDownloaded: updateDownloaded ?? this.updateDownloaded,
      restarting: restarting ?? this.restarting,
      currentPatchNumber: currentPatchNumber ?? this.currentPatchNumber,
      nextPatchNumber: nextPatchNumber ?? this.nextPatchNumber,
      lastChecked: lastChecked ?? this.lastChecked,
      error: error ?? this.error,
    );
  }
}

final shorebirdNotifierProvider = StateNotifierProvider<ShorebirdNotifier, ShorebirdState>((ref) {
  final shorebird = ref.watch(shorebirdCodePushProvider);
  return ShorebirdNotifier(shorebird);
});