import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/exercise.dart';
import '../../../widgets/custom_button.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  Future<void> _launchVideoUrl(String? url) async {
    if (url == null) return;

    try {
      if (!await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      // Fallback: Show error or copy to clipboard
    }
  }

  Future<void> _launchTutorialUrl(String? url) async {
    if (url == null) return;

    try {
      if (!await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      // Fallback: Show error or copy to clipboard
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Exercise Type and Category Badges
            Row(
              children: [
                Chip(
                  label: Text(exercise.exerciseType.displayName),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(exercise.category),
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Video Section
            if (exercise.videoUrl != null) ...[
              const Text(
                'Demonstration Video',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Watch proper form and technique',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Watch Video',
                icon: Icons.play_arrow,
                onPressed: () => _launchVideoUrl(exercise.videoUrl),
              ),
              const SizedBox(height: 24),
            ],

            // Tutorial Section
            if (exercise.tutorialUrl != null) ...[
              const Text(
                'Detailed Tutorial',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Read step-by-step instructions',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Read Tutorial',
                icon: Icons.article,
                onPressed: () => _launchTutorialUrl(exercise.tutorialUrl),
              ),
              const SizedBox(height: 24),
            ],

            // Description
            if (exercise.description != null) ...[
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                exercise.description!,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
            ],

            // Target Muscles
            if (exercise.targetMuscles.isNotEmpty) ...[
              const Text(
                'Target Muscles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: exercise.targetMuscles.map((muscle) {
                  return Chip(
                    label: Text(muscle),
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // No Video/Tutorial Message
            if (exercise.videoUrl == null && exercise.tutorialUrl == null) ...[
              const Icon(
                Icons.video_library,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'No video or tutorial available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'We\'re working on adding more exercise resources!',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}