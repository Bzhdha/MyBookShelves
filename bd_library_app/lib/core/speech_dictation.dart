import 'package:speech_to_text/speech_to_text.dart';

/// Reconnaissance vocale pour remplir un champ (recherche, résumé, etc.).
class SpeechDictation {
  SpeechDictation({this.localeId = 'fr_FR'});

  final String localeId;
  final SpeechToText _stt = SpeechToText();
  bool _initialized = false;

  Future<bool> initialize() async {
    if (_initialized) return _stt.isAvailable;
    _initialized = await _stt.initialize();
    return _stt.isAvailable;
  }

  bool get isAvailable => _stt.isAvailable;
  bool get isListening => _stt.isListening;

  /// [baseText] : texte déjà présent avant cette session (ex. début du résumé).
  Future<void> startListening({
    required void Function(String text) onText,
    String baseText = '',
  }) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) return;
    }
    final prefix = baseText;
    await _stt.listen(
      onResult: (result) {
        final spacer = prefix.isNotEmpty &&
                result.recognizedWords.isNotEmpty &&
                !prefix.endsWith(' ') &&
                !prefix.endsWith('\n')
            ? ' '
            : '';
        onText('$prefix$spacer${result.recognizedWords}');
      },
      localeId: localeId,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        listenMode: ListenMode.dictation,
      ),
    );
  }

  Future<void> stop() => _stt.stop();
}
