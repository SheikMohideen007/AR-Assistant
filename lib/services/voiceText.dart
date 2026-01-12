// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:permission_handler/permission_handler.dart';

// class VoiceToTextModal extends StatefulWidget {
//   final Function(String text) onSend;

//   const VoiceToTextModal({super.key, required this.onSend});

//   @override
//   State<VoiceToTextModal> createState() => _VoiceToTextModalState();
// }

// class _VoiceToTextModalState extends State<VoiceToTextModal> {
//   final stt.SpeechToText _speech = stt.SpeechToText();

//   String _text = '';
//   String _status = 'Tap & hold to speak';
//   bool _isListening = false;
//   bool _hasSpeech = false;

//   @override
//   void initState() {
//     super.initState();
//     _initSpeech();
//   }

//   Future<void> _initSpeech() async {
//     final status = await Permission.microphone.request();
//     if (!status.isGranted) {
//       setState(() => _status = "Microphone permission denied");
//       return;
//     }

//     final bool available = await _speech.initialize(
//       onStatus: (val) => debugPrint('Status → $val'),
//       onError: (err) => debugPrint('Error → $err'),
//     );

//     if (!available) {
//       setState(() => _status = "Speech recognition not available");
//     }
//   }

//   Future<void> _startListening() async {
//     print('came here to start listening');
//     if (_isListening) return;
//     print('came here to start listening 2');
//     setState(() {
//       _text = '';
//       _status = "Listening... speak now!";
//       _isListening = true;
//     });
//     print('came here to start listening 3');

//     await _speech.listen(
//       onResult: _onSpeechResult,
//       partialResults: true,
//       listenFor: const Duration(seconds: 60),
//       pauseFor: const Duration(seconds: 10),
//       localeId: 'en_IN',
//       cancelOnError: false,
//       sampleRate: 16000,
//       onSoundLevelChange: (level) {
//         debugPrint("Sound level: $level dB"); // ← watch these numbers!
//       },
//     );
//   }

//   void _onSpeechResult(SpeechRecognitionResult result) {
//     if (!mounted) return;

//     setState(() {
//       _text = result.recognizedWords;
//       _hasSpeech = result.finalResult;
//       if (result.finalResult) {
//         _status = "Got it! Release to send";
//         debugPrint("Final result: $_text");
//       }
//     });
//   }

//   Future<void> _stopListening() async {
//     if (!_isListening) return;

//     await _speech.stop();
//     setState(() => _isListening = false);

//     String finalText = _text.trim();
//     if (finalText.isEmpty) {
//       finalText = "Didn't catch anything — try speaking louder/closer";
//     }

//     setState(() {
//       _status = "Result: $finalText";
//     });

//     await Future.delayed(const Duration(milliseconds: 1200));

//     if (mounted) {
//       widget.onSend(finalText);
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(_status, style: Theme.of(context).textTheme.titleMedium),
//           const SizedBox(height: 24),

//           if (_text.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 _text,
//                 style: Theme.of(context).textTheme.bodyLarge,
//                 textAlign: TextAlign.center,
//               ),
//             ),

//           const SizedBox(height: 32),

//           GestureDetector(
//             onTap: () {
//               if (_isListening) {
//                 _stopListening();
//               } else {
//                 _startListening();
//               }
//             },
//             child: AnimatedScale(
//               scale: _isListening ? 1.08 : 1.0,
//               duration: const Duration(milliseconds: 200),
//               curve: Curves.easeInOut,
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: _isListening
//                       ? Colors.red
//                       : Theme.of(context).primaryColor,
//                   boxShadow: [
//                     BoxShadow(
//                       color: _isListening
//                           ? Colors.redAccent.withOpacity(0.6)
//                           : Colors.black26,
//                       blurRadius: _isListening ? 20 : 12,
//                       offset: const Offset(0, 6),
//                       spreadRadius: _isListening ? 4 : 0,
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   _isListening ? Icons.stop_rounded : Icons.mic_rounded,
//                   size: 50,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),
//           Text(
//             _isListening ? "Release to send" : "Hold to speak",
//             style: TextStyle(color: Colors.grey[600]),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _speech.cancel();
//     super.dispose();
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:permission_handler/permission_handler.dart';

// class VoiceToTextModal extends StatefulWidget {
//   final Function(String text) onSend;

//   const VoiceToTextModal({super.key, required this.onSend});

//   @override
//   State<VoiceToTextModal> createState() => _VoiceToTextModalState();
// }

// class _VoiceToTextModalState extends State<VoiceToTextModal> {
//   final stt.SpeechToText _speech = stt.SpeechToText();

//   String _text = '';
//   String _status = 'Tap to start speaking';
//   bool _isListening = false;
//   bool _hasSpeech = false;

//   Timer? _silenceTimer;
//   double _lastSoundLevel = 0.0;
//   static const double _silenceThreshold = -45.0; // dB level considered silence
//   static const int _silenceSecondsToStop =
//       8; // auto-stop after this many seconds of silence

//   @override
//   void initState() {
//     super.initState();
//     _initSpeech();
//   }

//   Future<void> _initSpeech() async {
//     final status = await Permission.microphone.request();
//     if (!status.isGranted) {
//       setState(() => _status = "Microphone permission denied");
//       return;
//     }

//     final bool available = await _speech.initialize(
//       onStatus: (val) => debugPrint('Status → $val'),
//       onError: (err) => debugPrint('Error → $err'),
//     );

//     if (!available) {
//       setState(() => _status = "Speech recognition not available");
//     }
//   }

//   Future<void> _startListening() async {
//     if (_isListening) return;

//     setState(() {
//       _text = '';
//       _status = "Listening... Speak now!";
//       _isListening = true;
//     });

//     await _speech.listen(
//       onResult: _onSpeechResult,
//       partialResults: true,
//       listenFor: const Duration(seconds: 120),
//       pauseFor: const Duration(seconds: 15),
//       localeId: 'en_IN',
//       cancelOnError: false,
//       sampleRate: 16000,
//       onSoundLevelChange: _onSoundLevelChange,
//     );

//     // Start silence detection timer
//     _startSilenceTimer();
//   }

//   void _onSoundLevelChange(double level) {
//     _lastSoundLevel = level;
//     debugPrint("Sound level: $level dB");

//     // Reset silence timer when sound is detected (above threshold)
//     if (level > _silenceThreshold) {
//       _startSilenceTimer(); // Restart countdown
//     }
//   }

//   void _startSilenceTimer() {
//     _silenceTimer?.cancel();
//     _silenceTimer = Timer(const Duration(seconds: _silenceSecondsToStop), () {
//       if (_isListening && mounted) {
//         debugPrint("Auto-stopped due to silence");
//         _stopListening(autoStopped: true);
//       }
//     });
//   }

//   void _onSpeechResult(SpeechRecognitionResult result) {
//     if (!mounted) return;

//     setState(() {
//       _text = result.recognizedWords;
//       _hasSpeech = result.finalResult;
//       if (result.finalResult) {
//         _status = "Got it!";
//         debugPrint("Final result: $_text");
//       }
//     });
//   }

//   Future<void> _stopListening({bool autoStopped = false}) async {
//     if (!_isListening) return;

//     await _speech.stop();
//     _silenceTimer?.cancel();

//     setState(() {
//       _isListening = false;
//       _status = autoStopped ? "Auto-stopped (silence detected)" : "Stopped";
//     });

//     String finalText = _text.trim();
//     if (finalText.isEmpty) {
//       finalText = "Didn't catch anything — try again?";
//     }

//     setState(() {
//       // _status = "Result: $finalText";
//     });

//     debugPrint("Final text: '$finalText'");

//     await Future.delayed(const Duration(milliseconds: 1500));

//     if (mounted) {
//       finalText = randomToAFDA(finalText);
//       widget.onSend(finalText);
//       Navigator.pop(context); // Auto-close modal
//     }
//   }

//   randomToAFDA(String text) {
//     bool isHave =
//         text.contains('app') ||
//         text.contains('App') ||
//         text.contains('afta') ||
//         text.contains('Afta') ||
//         text.contains('After') ||
//         text.contains('after') ||
//         text.contains('FDA');
//     if ((text.contains('list') &&
//             text.contains('all the') &&
//             (text.contains('account') || text.contains('accounts'))) &&
//         isHave) {
//       return "list all the afda accounts";
//     }
//     return text;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(_status, style: Theme.of(context).textTheme.titleMedium),
//           const SizedBox(height: 24),

//           if (_text.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 _text = randomToAFDA(_text),
//                 style: Theme.of(context).textTheme.bodyLarge,
//                 textAlign: TextAlign.center,
//               ),
//             ),

//           const SizedBox(height: 32),

//           GestureDetector(
//             onTap: () {
//               if (_isListening) {
//                 _stopListening();
//               } else {
//                 _startListening();
//               }
//             },
//             child: AnimatedScale(
//               scale: _isListening ? 1.08 : 1.0,
//               duration: const Duration(milliseconds: 200),
//               curve: Curves.easeInOut,
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: _isListening
//                       ? Colors.red
//                       : Theme.of(context).primaryColor,
//                   boxShadow: [
//                     BoxShadow(
//                       color: _isListening
//                           ? Colors.redAccent.withOpacity(0.6)
//                           : Colors.black26,
//                       blurRadius: _isListening ? 20 : 12,
//                       offset: const Offset(0, 6),
//                       spreadRadius: _isListening ? 4 : 0,
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   _isListening ? Icons.stop_rounded : Icons.mic_rounded,
//                   size: 50,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),
//           Text(
//             _isListening ? "Tap to stop" : "Tap to speak",
//             style: TextStyle(color: Colors.grey[600]),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _silenceTimer?.cancel();
//     _speech.cancel();
//     super.dispose();
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceToTextModal extends StatefulWidget {
  final Function(String text) onSend;

  const VoiceToTextModal({super.key, required this.onSend});

  @override
  State<VoiceToTextModal> createState() => _VoiceToTextModalState();
}

class _VoiceToTextModalState extends State<VoiceToTextModal> {
  final stt.SpeechToText _speech = stt.SpeechToText();

  String _text = '';
  String _status = 'Tap to start speaking';
  bool _isListening = false;

  Timer? _silenceTimer;
  double _lastSoundLevel = 0.0;
  static const double _silenceThreshold = -45.0;
  static const int _silenceSecondsToStop = 8;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      setState(() => _status = "Microphone permission denied");
      return;
    }

    final bool available = await _speech.initialize(
      onStatus: (val) => debugPrint('Status → $val'),
      onError: (err) => debugPrint('Error → $err'),
    );

    if (!available) {
      setState(() => _status = "Speech recognition not available");
    }
  }

  Future<void> _startListening() async {
    if (_isListening) return;

    setState(() {
      _text = '';
      _status = "Listening... Speak now!";
      _isListening = true;
    });

    await _speech.listen(
      onResult: _onSpeechResult,
      partialResults: true,
      listenFor: const Duration(seconds: 120),
      pauseFor: const Duration(seconds: 15),
      localeId: 'en_IN',
      cancelOnError: false,
      sampleRate: 16000,
      onSoundLevelChange: _onSoundLevelChange,
    );

    _startSilenceTimer();
  }

  void _onSoundLevelChange(double level) {
    _lastSoundLevel = level;
    debugPrint("Sound level: $level dB");

    if (level > _silenceThreshold) {
      _startSilenceTimer();
    }
  }

  void _startSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: _silenceSecondsToStop), () {
      if (_isListening && mounted) {
        debugPrint("Auto-stopped due to silence");
        _stopListening(autoStopped: true);
      }
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;

    setState(() {
      _text = result.recognizedWords;
      if (result.finalResult) {
        _status = "Got it!";
        debugPrint("Final result received: $_text");

        // Auto-close after showing "Got it!" for a moment
        _handleFinalResult(result.recognizedWords);
      }
    });
  }

  // New method: Handles final result → delay → send & close
  Future<void> _handleFinalResult(String finalText) async {
    // Stop listening immediately
    await _speech.stop();
    _silenceTimer?.cancel();
    setState(() => _isListening = false);

    String processedText = finalText.trim();
    if (processedText.isEmpty) {
      processedText = "Didn't catch anything — try again?";
    }

    // Apply your randomToAFDA logic
    processedText = randomToAFDA(processedText);

    // Show result briefly
    setState(() {
      _text = processedText;
      _status = "Got it! Sending...";
    });

    debugPrint("Final processed text: '$processedText'");

    await Future.delayed(const Duration(milliseconds: 1200)); // Let user see it

    if (mounted) {
      widget.onSend(processedText);
      Navigator.pop(context); // Auto-close modal
    }
  }

  Future<void> _stopListening({bool autoStopped = false}) async {
    if (!_isListening) return;

    await _speech.stop();
    _silenceTimer?.cancel();

    setState(() {
      _isListening = false;
      _status = autoStopped ? "Auto-stopped (silence)" : "Stopped";
    });

    // If manual stop, still process what we have
    String finalText = _text.trim();
    if (finalText.isEmpty) {
      finalText = "Didn't catch anything — try again?";
    }

    finalText = randomToAFDA(finalText);

    setState(() {
      _status = "Result: $finalText";
    });

    debugPrint("Manual stop - Final text: '$finalText'");

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      widget.onSend(finalText);
      Navigator.pop(context);
    }
  }

  String randomToAFDA(String text) {
    bool hasAFDA =
        text.toLowerCase().contains('app') ||
        text.contains('afta') ||
        text.contains('After') ||
        text.contains('after') ||
        text.contains('FDA');

    if (text.toLowerCase().contains('list') &&
        text.toLowerCase().contains('all the') &&
        (text.toLowerCase().contains('account') ||
            text.toLowerCase().contains('accounts')) &&
        hasAFDA) {
      return "list all the afda accounts";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_status, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),

          if (_text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _text,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 32),

          GestureDetector(
            onTap: () {
              if (_isListening) {
                _stopListening();
              } else {
                _startListening();
              }
            },
            child: AnimatedScale(
              scale: _isListening ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening
                      ? Colors.red
                      : Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: _isListening
                          ? Colors.redAccent.withOpacity(0.6)
                          : Colors.black26,
                      blurRadius: _isListening ? 20 : 12,
                      offset: const Offset(0, 6),
                      spreadRadius: _isListening ? 4 : 0,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          Text(
            _isListening ? "Tap to stop" : "Tap to speak",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _speech.cancel();
    super.dispose();
  }
}
