import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/note.dart';
import '../providers/note_provider.dart';

class AudioRecorderWidget extends StatefulWidget {
  final Note? note;
  final Function(String transcription)? onTranscription;

  const AudioRecorderWidget({super.key, this.note, this.onTranscription});

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  bool _isRecording = false;
  
  void _toggleRecording() async {
    if (!_isRecording) {
      setState(() {
        _isRecording = true;
      });
    } else {
      setState(() => _isRecording = false);

      // Audio transcription not available in offline mode
      if (widget.note != null) {
        await context.read<NoteProvider>().transcribeNoteAudio(widget.note!, '');
      } else if (widget.onTranscription != null) {
        widget.onTranscription!('Transcrição de áudio não disponível no modo offline.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isRecording) ...[
          const Text('Gravando...', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
        ],
        IconButton(
          icon: Icon(_isRecording ? Icons.stop_circle : Icons.mic, size: 48),
          color: _isRecording ? AppColors.danger : AppColors.deepOceanBlue,
          onPressed: _toggleRecording,
        ),
        Text(_isRecording ? 'Clique para parar' : 'Gravar Áudio'),
      ],
    );
  }
}
