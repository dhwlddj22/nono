import 'dart:async';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:path_provider/path_provider.dart';
import 'chatgpt_service.dart';

class RecordingService {
  FlutterSoundRecorder? _recorder;
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  List<double> _decibelReadings = [];
  String? _filePath;

  Future<void> startRecording() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
    _filePath = '${(await getApplicationDocumentsDirectory()).path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder!.startRecorder(toFile: _filePath);

    _noiseMeter = NoiseMeter();
    _noiseSubscription = _noiseMeter!.noise.listen((noiseReading) {
      _decibelReadings.add(noiseReading.meanDecibel);
    });
  }

  Future<void> stopRecording() async {
    await _recorder?.stopRecorder();
    await _recorder?.closeRecorder();
    _recorder = null;

    await _noiseSubscription?.cancel();
    _noiseSubscription = null;

    double averageDecibel = _decibelReadings.reduce((a, b) => a + b) / _decibelReadings.length;
    _decibelReadings.clear();

    if (_filePath != null) {
      await ChatGPTService.sendToChatGPT(averageDecibel, _filePath!);
    }
  }
}
