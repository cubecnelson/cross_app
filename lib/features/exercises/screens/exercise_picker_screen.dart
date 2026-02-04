import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/exercise_provider.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/empty_state.dart';
import 'add_exercise_screen.dart';
import 'exercise_detail_screen.dart';

class ExercisePickerScreen extends ConsumerStatefulWidget {
  const ExercisePickerScreen({super.key});

  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exercise'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              
              // Category Filter
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategoryChip('All'),
                    ...AppConstants.exerciseCategories
                        .map((cat) => _buildCategoryChip(cat)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: exercises.when(
        data: (exercisesList) {
          var filteredExercises = exercisesList;

          // Filter by search
          if (_searchController.text.isNotEmpty) {
            filteredExercises = filteredExercises
                .where((e) => e.name
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
                .toList();
          }

          // Filter by category
          if (_selectedCategory != 'All') {
            filteredExercises = filteredExercises
                .where((e) => e.category == _selectedCategory)
                .toList();
          }

          if (filteredExercises.isEmpty) {
            return EmptyState(
              icon: Icons.search_off,
              title: 'No exercises found',
              message: 'Try a different search or category',
              actionText: 'Create Custom Exercise',
              onAction: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddExerciseScreen(),
                  ),
                );
                ref.invalidate(exercisesProvider);
              },
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredExercises.length,
            itemBuilder: (context, index) {
              final exercise = filteredExercises[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(exercise.name[0].toUpperCase()),
                  ),
                  title: Text(exercise.name),
                  subtitle: Text(exercise.category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (exercise.videoUrl != null || exercise.tutorialUrl != null)
                        const Icon(Icons.video_library, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      exercise.isPredefined
                          ? const Icon(Icons.library_books, size: 16)
                          : const Icon(Icons.person, size: 16),
                    ],
                  ),
                  onTap: () => Navigator.pop(context, exercise),
                  onLongPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseDetailScreen(exercise: exercise),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading exercises...'),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(exercisesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExerciseScreen(),
            ),
          );
          ref.invalidate(exercisesProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
      ),
    );
  }
}

