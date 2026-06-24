import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/note.dart';

class AudioRecorderWidget extends StatelessWidget {
  final Note? note;
  final Function(String transcription)? onTranscription;

  const AudioRecorderWidget({super.key, this.note, this.onTranscription});

  void _showUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gravação de áudio não disponível nesta versão.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.mic, size: 24),
      color: AppColors.categoryAudio,
      tooltip: 'Gravar Áudio',
      onPressed: () => _showUnavailable(context),
    );
  }
}
