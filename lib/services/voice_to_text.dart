import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceToTextModal extends StatefulWidget {
  final Function(String transcribedText) onSendText;

  const VoiceToTextModal({super.key, required this.onSendText});

  @override
  State<VoiceToTextModal> createState() => _VoiceToTextModalState();
}

class _VoiceToTextModalState extends State<VoiceToTextModal> {
  AudioRecorder? _recorder;
  final stt.SpeechToText _speech = stt.SpeechToText();

  String _recordedFilePath = '';
  String _transcribedText = '';
  bool _isRecording = false;
  bool _isProcessing = false;
  String _statusText = "Tap & hold to record";

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _recorder = AudioRecorder();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      if (mounted) setState(() => _statusText = "Microphone permission denied");
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) => debugPrint('Speech status: $status'),
      onError: (error) => debugPrint('Speech error: $error'),
    );

    if (!available && mounted) {
      setState(
        () => _statusText = "Speech recognition not available on device",
      );
    }
  }

  Future<void> _startRecording() async {
    if (_isDisposed || _recorder == null || !mounted) return;

    if (!await _recorder!.hasPermission()) {
      setState(() => _statusText = "Microphone permission denied");
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      _recordedFilePath =
          '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder!.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
        path: _recordedFilePath,
      );

      if (!mounted) return;

      setState(() {
        _isRecording = true;
        _statusText = "Recording... Speak clearly (release to stop)";
        _transcribedText = '';
      });

      debugPrint("Recording started to: $_recordedFilePath");

      await _speech.listen(
        onResult: _onSpeechResult,
        partialResults: true,
        listenFor: const Duration(seconds: 120), // much longer
        pauseFor: const Duration(seconds: 15),
        localeId: 'en_IN', // Indian English
        cancelOnError: false,
        sampleRate: 16000, // better compatibility
      );
    } catch (e) {
      debugPrint("Start error: $e");
      if (mounted) setState(() => _statusText = "Failed to start: $e");
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (mounted) {
      setState(() {
        _transcribedText = result.recognizedWords;
      });
      debugPrint("Live transcription: $_transcribedText");
    }
  }

  Future<void> _stopAndProcess() async {
    if (!_isRecording || _isDisposed || _recorder == null || !mounted) return;

    setState(() {
      _isRecording = false;
      _isProcessing = true;
      _statusText = "Stopping & transcribing...";
    });

    // Stop recording first
    try {
      await _recorder!.stop();
      debugPrint("Recording stopped. File: $_recordedFilePath");
    } catch (e) {
      debugPrint("Stop recording error (often safe): $e");
    }

    // Stop speech
    try {
      await _speech.stop();
    } catch (e) {
      debugPrint("Stop speech error: $e");
    }

    if (!mounted) return;

    // Force final result (speech_to_text sometimes needs this)
    String finalText = _speech.lastRecognizedWords ?? _transcribedText;
    if (finalText.trim().isEmpty) {
      finalText = "No speech detected"; // Fallback
    }

    setState(() {
      _transcribedText = finalText;
      _statusText = "Transcription: $finalText";
      _isProcessing = false;
    });

    debugPrint("Final transcription to send: $finalText");

    await Future.delayed(
      const Duration(milliseconds: 1200),
    ); // Give UI time to show

    if (_transcribedText.trim().isNotEmpty && mounted) {
      widget.onSendText(_transcribedText.trim());
      debugPrint("Sent transcription to chat: $_transcribedText");
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _statusText,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          if (_transcribedText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                _transcribedText,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 24),

          GestureDetector(
            onTapDown: (_) => _startRecording(),
            onTapUp: (_) => _stopAndProcess(),
            onTapCancel: () => _stopAndProcess(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording
                    ? Colors.red
                    : Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: _isRecording ? Colors.redAccent : Colors.black26,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                _isRecording ? Icons.stop_rounded : Icons.mic,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text(
            _isRecording ? "Release to send" : "Tap & hold to record",
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _recorder?.dispose();
    _recorder = null;
    _speech.cancel();
    super.dispose();
  }
}
